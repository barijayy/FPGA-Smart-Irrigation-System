// PROJECT: Automatic Irrigation System
// SENSOR: JXCT Soil 7-in-1 Modbus RS485 (5V)
// DEVICE: Xilinx FPGA XC7A35T Artix-7

module irrigation_system (
    input wire clk, // FPGA system clock
    input wire rst, // Active-high reset
    input wire rx,  // RS485 UART receive line (Modbus)
    
    // 7 Sensor Parameters (decoded from Modbus RS485 frame)
    input wire [11:0] moisture, 
    input wire [11:0] temperature, 
    input wire [11:0] ec, 
    input wire [11:0] ph, 
    input wire [11:0] nitrogen, 
    input wire [11:0] phosphorus, 
    input wire [11:0] potassium, 

    // Outputs
    output reg pump, // Water pump relay control
    output reg led_green, // Green LED: Pump ON
    output reg led_red, // Red LED: Pump OFF / Alert
    output reg alert, // Alert: unsafe soil condition
    
    // RS485 Modbus TX (for requesting next sensor read)
    output reg tx, 
    output reg [7:0] modbus_cmd // Modbus RTU command byte
);

    // THRESHOLD CONSTANTS (Pre-set in FPGA logic fabric)
    localparam MOIST_LOW = 12'd300; // Below 30.0% -> DRY
    localparam MOIST_HIGH = 12'd700; // Above 70.0% -> WET
    localparam TEMP_MAX = 12'd450; // Above 45.0°C -> Unsafe
    localparam EC_MAX = 12'd2000; // Above 2000 uS/cm -> Saline
    localparam PH_LOW = 12'd50; // Below pH 5.0 -> Acidic
    localparam PH_HIGH = 12'd85; // Above pH 8.5 -> Alkaline
    localparam N_LOW = 12'd50; // Below 50 mg/kg -> N deficiency
    localparam P_LOW = 12'd30; // Below 30 mg/kg -> P deficiency
    localparam K_LOW = 12'd100; // Below 100 mg/kg -> K deficiency

    // STATE MACHINE STATES
    localparam IDLE = 2'b00;
    localparam READ_SENSOR = 2'b01;
    localparam PROCESS = 2'b10;
    localparam OUTPUT = 2'b11;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    wire soil_dry, soil_wet, temp_safe, ec_safe, ph_safe, nutrients_ok, safe_to_irrigate;

    // Condition logic (combinational)
    assign soil_dry = (moisture < MOIST_LOW);
    assign soil_wet = (moisture >= MOIST_HIGH);
    assign temp_safe = (temperature < TEMP_MAX);
    assign ec_safe = (ec < EC_MAX);
    assign ph_safe = (ph >= PH_LOW) && (ph <= PH_HIGH);
    assign nutrients_ok = (nitrogen >= N_LOW) && (phosphorus >= P_LOW) && (potassium >= K_LOW);
    assign safe_to_irrigate = temp_safe && ec_safe && ph_safe;

    // STATE REGISTER
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    // NEXT STATE LOGIC
    always @(*) begin
        case (state)
            IDLE: next_state = READ_SENSOR;
            READ_SENSOR: next_state = PROCESS;
            PROCESS: next_state = OUTPUT;
            OUTPUT: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // OUTPUT LOGIC
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pump <= 1'b0;
            led_green <= 1'b0;
            led_red <= 1'b1;
            alert <= 1'b0;
            tx <= 1'b0;
            modbus_cmd <= 8'h00;
        end else if (state == OUTPUT) begin
            
            // UNSAFE CONDITION: Do NOT irrigate
            if (!safe_to_irrigate) begin
                pump <= 1'b0;
                led_green <= 1'b0;
                led_red <= 1'b1;
                alert <= 1'b1; 
            end
            
            // SAFE + DRY: Activate pump
            else if (soil_dry && safe_to_irrigate) begin
                pump <= 1'b1;
                led_green <= 1'b1;
                led_red <= 1'b0;
                alert <= 1'b0;
            end
            
            // SAFE + WET: Pump OFF
            else if (soil_wet) begin
                pump <= 1'b0;
                led_green <= 1'b0;
                led_red <= 1'b1;
                alert <= 1'b0;
            end
            
            // NUTRIENT CHECK
            if (!nutrients_ok) begin
                alert <= 1'b1; 
            end
        end else if (state == READ_SENSOR) begin
            modbus_cmd <= 8'h03; // Function code: Read Holding Registers
            tx <= 1'b1; // Initiate read cycle
        end else begin
            tx <= 1'b0;
        end
    end
endmodule