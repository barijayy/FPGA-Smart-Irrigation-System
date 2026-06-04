# 🌾 FPGA-Based Automatic Smart Irrigation System

An intelligent, deterministic, hardware-level irrigation controller utilizing a **Xilinx XC7A35T Artix-7 FPGA** programmed entirely in **Verilog HDL**. 

Conventional automatic irrigation systems waste up to 40-60% of water and fail to account for the multi-dimensional nature of soil health. This system interfaces with an industrial JXCT 7-in-1 Soil Sensor via Modbus RTU RS485 to evaluate seven distinct soil parameters (Moisture, Temperature, EC, pH, Nitrogen, Phosphorus, Potassium) in parallel. By making real-time, multi-variable watering decisions, the system prevents severe crop damage caused by thermal shock, soil salinity spikes, and pH-induced nutrient lockout.

### 🚀 Live Interactive Simulator
Because this project requires specific industrial sensors and FPGA hardware, our team engineered a custom interactive web simulator to demonstrate the hardware logic directly in the browser. 

🔗 **[Launch the FPGA Irrigation Web Simulator](https://grp9-fpgasim.netlify.app/)**

---

## ⚠️ The Agronomic Problem with Traditional Systems
Most automated systems (including basic Arduino/ESP32 setups) rely on a single binary logic flow: *If soil moisture is low, turn the pump on*. This approach is agronomically dangerous:
* **High Salinity Hazard:** If the soil's Electrical Conductivity (EC) is > 2000 µS/cm, the soil is highly saline. Irrigating saline soil further concentrates salts, causing irreversible osmotic stress to plant roots.
* **Thermal Shock:** Irrigating crops with cold water when the soil temperature exceeds 45°C causes immediate physiological damage.
* **Nutrient Lockout:** Soil pH outside the 5.0 to 8.5 range prevents roots from absorbing nutrients. Irrigating imbalanced soil simply leaches the remaining nutrients.
* **Sequential Latency:** Microcontrollers process multi-parameter sensor arrays sequentially, introducing latency in high-speed control loops. 

This FPGA architecture solves these issues by processing all 7 parameters simultaneously in a single clock cycle using deterministic hardware combinational logic.

---

## 🛠️ Hardware Architecture & Components
The architecture replaces software-dependent microcontrollers with a precise hardware workflow.

1. **Sensing Layer (JXCT 7-in-1 Sensor):** An industrial-grade, IP68-rated capacitive probe operating at 5V DC. It continuously samples soil data and processes it using an internal microprocessor to format a Modbus RTU response frame.
2. **Communication Layer (MAX485 Transceiver):** Bridges the differential RS485 electrical signals (A+/B- lines) from the Modbus bus into standard UART-compatible TTL serial signals for the FPGA's GPIO pins.
3. **Processing Layer (Xilinx XC7A35T Artix-7):** The main control unit containing 33,280 Logic Cells. It evaluates the decoded 12-bit sensor values against hardwired LUT threshold constants without the overhead of an operating system.
4. **Output Driver (BC547 NPN Transistor):** The FPGA's 3.3V GPIO pins (max ~8mA) cannot drive a 300mA motor directly. The BC547 acts as a low-side switch, saturating the base via a 220-ohm resistor to complete the pump's ground circuit. A 1N4007 flyback diode protects the circuit from back-EMF spikes.

---

## 📡 Modbus RS485 Communication Protocol
The system uses a half-duplex RS485 bus at a 4800 baud rate (8 data bits, 1 stop bit, no parity). 
* **Master (FPGA):** Initiates communication by transmitting an 8-byte request frame (Function Code `0x03` - Read Holding Registers).
* **Slave (JXCT Sensor):** Responds with a 25-byte frame. Registers `R0` through `R6` correspond directly to the 7 parameters, encoded as 16-bit unsigned integers.

---

## ⚙️ Finite State Machine (FSM) Logic
The FSM is implemented as a 4-state Moore/Mealy machine transitioning on every rising clock edge:
1. `IDLE`: Initializes all output registers to default safe states (Pump OFF, Alert OFF, Red LED ON).
2. `READ_SENSOR`: Asserts the TX line to send the `0x03` Modbus request frame. Waits for the 25-byte response.
3. `PROCESS`: Evaluates all 7 combinational condition wires instantly in a single clock cycle.
4. `OUTPUT`: Drives the pump and LEDs. 

**Safety Thresholds:**
The pump is **ONLY** activated if the soil is dry **AND** all environmental safety conditions are met. 
* `MOIST_LOW < 30%` -> Flagged as DRY
* `TEMP_MAX > 45.0°C` -> **UNSAFE** (Pump disabled)
* `EC_MAX > 2000 µS/cm` -> **UNSAFE** (Pump disabled)
* `PH_LOW < 5.0` or `PH_HIGH > 8.5` -> **UNSAFE** (Pump disabled)
* `N < 50 mg/kg`, `P < 30 mg/kg`, `K < 100 mg/kg` -> **Nutrient Deficiency Alert Triggered**

---

## 🖥️ Custom Web Simulator Features
The frontend interface (`index.html`) was built from scratch using HTML5, CSS3, and JavaScript to proxy the physical hardware. 
* **Live Schematic:** Features an animated SVG circuit diagram showing signal flows between the sensor, the FPGA, the BC547 transistor, and the DC motor.
* **Real-Time Waveforms:** An HTML5 Canvas element generates real-time EPWave-style logic transitions based on user inputs.
* **Robust UI Management:** The frontend accurately mimics hardware states while avoiding DOM hidden-state bugs by strictly mapping component toggles to `display: 'flex'` instead of empty display values.

---

## 📂 Repository Contents
* `irrigation_system.v`: The top-level synthesizable Verilog HDL code containing the FSM, UART/RS485 decoding logic, and combinational comparators.
* `index.html`: The complete source code for the custom HTML5/JS web simulator hosted on Netlify.
* `FPGA_Sim_Synopsis_Report.pdf`: The comprehensive project report, including the full literature survey, detailed hardware specifications, schematic breakdowns, and Modbus frame math.
* `FPGA_Sim_One_Page_Report.pdf`: A concise, 1-page high-level architectural summary of the project goals and block diagram.

---

## 🚀 Future Scope
* **IoT Dashboard Integration:** Transmitting sensor data via ESP32/Wi-Fi to an MQTT broker for real-time cloud monitoring (ThingSpeak/Blynk).
* **Solar Integration:** Leveraging the XC7A35T's low 300mW quiescent power consumption to run the system entirely off a 10W, 12V solar panel for remote deployment.
* **Automated Fertigation:** Linking the N-P-K deficiency alerts to an automated fertilizer injection pump.

---

## 👤 Author
**Jay Digesh Bari**  
*Third-Year Electronics & Telecommunication Engineering Student*  
*Atharva College of Engineering*
