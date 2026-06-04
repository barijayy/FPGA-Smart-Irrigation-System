# 🌾 FPGA-Based Automatic Smart Irrigation System

An intelligent, deterministic, hardware-level irrigation controller utilizing a **Xilinx XC7A35T Artix-7 FPGA** programmed entirely in **Verilog HDL**. 

This system interfaces with an industrial JXCT 7-in-1 Soil Sensor via Modbus RTU RS485 to evaluate seven distinct soil parameters in parallel. By making real-time, multi-variable watering decisions, the system prevents severe crop damage caused by thermal shock, soil salinity spikes, and pH-induced nutrient lockout.

### 🚀 Live Interactive Simulator
To demonstrate the hardware logic without requiring a physical FPGA development board, our team engineered a custom interactive web simulator. 

🔗 **[Launch the FPGA Irrigation Web Simulator](https://grp9-fpgasim.netlify.app/)**

---

## ⚠️ The Problem with Traditional Systems
Most automated irrigation systems—including those built on standard microcontrollers—rely on a single binary logic flow: *If soil moisture is low, turn the pump on.* This approach is agronomically dangerous:
* **High Salinity Hazard:** If the soil's Electrical Conductivity (EC) is > 2000 µS/cm, the soil is highly saline. Irrigating saline soil further concentrates salts, causing irreversible osmotic stress to plant roots.
* **Thermal Shock:** Irrigating crops with cold water when the soil temperature exceeds 45°C causes immediate physiological damage.
* **Nutrient Lockout:** Soil pH outside the 5.0 to 8.5 range prevents roots from absorbing nutrients. Irrigating imbalanced soil wastes water.
* **Sequential Latency:** Microcontrollers process multi-parameter sensor arrays sequentially. 

This FPGA architecture solves these issues by processing all 7 parameters simultaneously in a single clock cycle using deterministic hardware combinational logic.

---

## 🛠️ Hardware Architecture
The architecture replaces software-dependent microcontrollers with a 4-state Mealy Finite State Machine (FSM) embedded in the FPGA logic fabric.

1. **Sensing Layer (JXCT 7-in-1 Sensor):** An industrial-grade, IP68-rated capacitive probe that simultaneously measures Moisture, Temperature, EC, pH, Nitrogen (N), Phosphorus (P), and Potassium (K).
2. **Communication Layer (MAX485):** A transceiver module that bridges the differential RS485 electrical signals from the Modbus bus into standard UART-compatible TTL signals for the FPGA.
3. **Processing Layer (Xilinx Artix-7 FPGA):** Runs the Verilog FSM (`IDLE` -> `READ_SENSOR` -> `PROCESS` -> `OUTPUT`). It evaluates the decoded 12-bit sensor values against hardwired LUT threshold constants.
4. **Output Layer (BC547 Transistor):** The FPGA's 3.3V GPIO pins cannot drive a motor. An NPN transistor acts as a low-side switch, saturating the base to drive a 5V DC submersible water pump.

---

## ⚙️ FSM Logic & Safety Thresholds
The pump is **ONLY** activated if the soil is dry **AND** all environmental safety conditions are met. 

* `MOIST_LOW < 30%` -> Flagged as DRY
* `TEMP_MAX > 45.0°C` -> **UNSAFE** (Pump disabled)
* `EC_MAX > 2000 µS/cm` -> **UNSAFE** (Pump disabled)
* `PH_LOW < 5.0` or `PH_HIGH > 8.5` -> **UNSAFE** (Pump disabled)
* `N < 50 mg/kg`, `P < 30 mg/kg`, `K < 100 mg/kg` -> **Nutrient Deficiency Alert Triggered**

---

## 🖥️ Custom Web Simulator Features
The frontend interface (`index.html`) was built from scratch using HTML5, CSS3, and JavaScript to proxy the physical hardware. 
* **Live Schematic:** Features an animated SVG circuit diagram showing signal flows between the sensor, FPGA, transistor, and DC motor.
* **Real-Time Waveforms:** An HTML5 Canvas element generates real-time EPWave-style logic transitions based on user inputs.
* **Robust State Management:** The frontend ensures smooth UI transitions across the different interface panels, utilizing precise JavaScript DOM manipulation (such as mapping elements to `display: 'flex'` to prevent CSS visibility conflicts during rapid state changes).

## 📂 Repository Contents
* `irrigation_system.v`: The top-level synthesizable Verilog HDL code containing the FSM, UART/RS485 decoding logic, and combinational comparators.
* `index.html`: The complete source code for the custom web simulator.
* `Gro 9 FPGA final SYNOPSIS.pdf`: The comprehensive project report, including literature survey, hardware specifications, schematic breakdowns, and Modbus frame math.
* `grp 9 final one page.pdf`: A concise, 1-page high-level architectural summary.
* `/images`: Circuit schematics, block diagrams, and EPWave simulation verification screenshots.

---

## 🔬 Simulation & Verification Tools
* **EDA Playground (Icarus Verilog):** Used for primary HDL behavioral simulation and testbench verification.
* **EPWave:** Used to visualize and verify the Value Change Dump (VCD) waveform files.
* **Xilinx Vivado:** Used for logic synthesis, mapping, and bitstream generation. 
* **Tinkercad Circuits:** Used for secondary system-level electrical proxy simulation.

---

## 👤 Author
**Jay Digesh Bari**  
*Third-Year Electronics & Telecommunication Engineering Student*  
*Atharva College of Engineering, Mumbai*
