# FPGA-Based Automatic Smart Irrigation System 🌱

An intelligent, deterministic, hardware-level irrigation controller using a **Xilinx XC7A35T Artix-7 FPGA** programmed in **Verilog HDL**. 

This system interfaces with an industrial JXCT 7-in-1 Soil Sensor via Modbus RTU RS485 to simultaneously evaluate seven soil parameters (Moisture, Temperature, EC, pH, Nitrogen, Phosphorus, and Potassium) in parallel, making real-time watering decisions to prevent crop damage from thermal shock, soil salinity, and nutrient lockout.

### 🚀 Live Interactive Simulator
To demonstrate the hardware logic without needing a physical FPGA, our team built a custom interactive web simulator. 
**Try the simulator here:** [FPGA Irrigation Web Simulator](https://grp9-fpgasim.netlify.app/)

---

## 🛠️ Hardware Architecture
The system replaces traditional sequential microcontroller logic with a 4-state Mealy Finite State Machine (FSM) implemented in FPGA hardware fabric.
1. **Sensing Layer:** JXCT 7-in-1 industrial soil probe.
2. **Communication Layer:** MAX485 Transceiver converting RS485 differential signals to UART.
3. **Processing Layer:** Xilinx Artix-7 FPGA running custom Verilog HDL logic. Evaluates 7 parameters simultaneously in a single clock cycle against hardwired safety thresholds.
4. **Output Layer:** NPN Transistor (BC547) acting as a low-side switch to drive a 5V DC Water Pump, along with LED status indicators.

## 📂 Repository Contents
* `irrigation_system.v`: The top-level Verilog HDL source code containing the FSM, RS485 decoding logic, and combinational threshold comparators.
* `index.html`: The source code for the custom HTML5/JS web simulator hosted on Netlify.
* `Gro 9 FPGA final SYNOPSIS.pdf`: The complete, extensive project report, including literature survey, hardware specifications, and Modbus frame decoding math.
* `grp 9 final one page.pdf`: A quick 1-page summary of the project architecture.

## ⚙️ How the FPGA Logic Works
Traditional irrigation systems only check if the soil is "dry". This system uses combinational logic to ensure all environmental variables are safe before irrigating:
* If the soil's Electrical Conductivity (EC) is > 2000 µS/cm, the soil is saline. Irrigating will concentrate salts and destroy roots. **Pump stays OFF.**
* If soil Temperature is > 45°C, irrigating causes thermal shock. **Pump stays OFF.**
* If soil pH is highly acidic or alkaline, nutrients are locked out. **Pump stays OFF.**
* If N, P, or K levels drop, an alert LED is triggered.

## 👤 Author
* **Jay Digesh Bari** - Third-Year Electronics & Telecommunication Engineering Student
* *Atharva College of Engineering*
