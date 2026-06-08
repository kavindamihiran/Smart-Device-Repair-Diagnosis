% =========================================================
% Module 2: Fault Information
% =========================================================
% fault_info(FaultAtom, Device, Label, Severity, Cost, Advice).
%
% Device: laptop | phone
% Severity: low | medium | high | critical
% Cost: low | medium | high

:- multifile fault_info/6.

fault_info(battery_failure, laptop, "Battery Failure", high, medium,
    "Replace the battery. Also check adapter health and charging cycle count.").
fault_info(charger_or_port_issue, laptop, "Charger or Charging Port Issue", medium, low,
    "Test with another adapter. Clean or replace the charging port if needed.").
fault_info(cooling_problem, laptop, "Cooling System Problem", high, medium,
    "Clean the fan, replace thermal paste, and check air vents.").
fault_info(display_damage, laptop, "Display Cable or Panel Damage", high, high,
    "Check display cable first. If the panel is damaged, replace the screen.").
fault_info(storage_failure, laptop, "Hard Disk / SSD Failure", critical, high,
    "Stop using the device heavily. Test storage health and replace storage if needed.").
fault_info(malware_infection, laptop, "Malware or Unwanted Software", medium, low,
    "Run a trusted malware scan, remove suspicious apps, and update the OS.").
fault_info(ram_or_os_crash, laptop, "RAM Issue or Operating System Crash", high, medium,
    "Run memory diagnostics. Re-seat RAM or repair/reinstall the OS.").
fault_info(keyboard_fault, laptop, "Keyboard Hardware Fault", medium, medium,
    "Check keyboard connector. Replace keyboard if multiple keys fail.").
fault_info(wifi_adapter_fault, laptop, "Wi-Fi Adapter or Driver Fault", medium, low,
    "Reinstall network driver. If still failing, test or replace Wi-Fi adapter.").
fault_info(power_thermal_issue, laptop, "Power and Thermal Issue", high, medium,
    "Check battery health, fan operation, and heat buildup. Clean cooling parts before replacing hardware.").
fault_info(thermal_boot_instability, laptop, "Thermal Boot Instability", high, medium,
    "Clean the cooling system, check thermal paste, and run OS and memory diagnostics.").
fault_info(storage_or_system_crash, laptop, "Storage or System Crash", critical, high,
    "Test storage health and repair or reinstall the operating system.").
fault_info(battery_charging_issue, laptop, "Battery and Charging Issue", high, medium,
    "Check the adapter, charging port, and battery health before replacing parts.").
fault_info(motherboard_power_issue, laptop, "Motherboard Power Issue", critical, high,
    "Test charger and battery first. If power still fails, inspect motherboard power circuit.").
fault_info(display_or_graphics_issue, laptop, "Display or Graphics Issue", high, high,
    "Check the display cable and external monitor output. Repair graphics or display hardware if needed.").
fault_info(system_performance_issue, laptop, "System Performance Issue", medium, low,
    "Remove unwanted programs, update the OS, and check storage and memory health.").
fault_info(os_boot_problem, laptop, "Operating System Boot Problem", high, medium,
    "Repair startup files, check recent updates, and reinstall the OS only if repair fails.").
fault_info(software_crash_or_malware, laptop, "Software Crash or Malware Issue", medium, low,
    "Remove suspicious software, scan for malware, update drivers, and check system stability.").
fault_info(power_display_startup_issue, laptop, "Power or Display Startup Issue", critical, high,
    "Test charger and battery first, then check display output and motherboard power circuit.").

fault_info(phone_battery_failure, phone, "Phone Battery Failure", high, medium,
    "Replace battery. Check charging IC if battery replacement does not solve it.").
fault_info(phone_charging_port_issue, phone, "Charging Port Issue", medium, low,
    "Clean charging port carefully. Replace port if cable does not fit firmly.").
fault_info(phone_display_damage, phone, "Display or Touch Panel Damage", high, high,
    "Replace display assembly if screen/touch is damaged.").
fault_info(phone_storage_overload, phone, "Storage Overload", medium, low,
    "Delete unnecessary files, clear app cache, and remove unused apps.").
fault_info(phone_water_damage, phone, "Water Damage", critical, high,
    "Power off immediately. Do not charge. Take to service center for board cleaning.").
fault_info(phone_camera_fault, phone, "Camera Module Fault", medium, medium,
    "Check camera permission and app first. Replace camera module if hardware issue remains.").
fault_info(phone_speaker_fault, phone, "Speaker or Audio IC Fault", medium, medium,
    "Clean speaker grill. If sound is absent, test and replace speaker module.").
fault_info(phone_network_fault, phone, "Network / Wi-Fi Fault", medium, low,
    "Reset network settings, update software, and check antenna or Wi-Fi module.").
fault_info(phone_boot_loop_fault, phone, "Boot Loop / Firmware Issue", critical, medium,
    "Repair firmware and check for failed updates or damaged system files.").
fault_info(phone_power_thermal_issue, phone, "Phone Power and Thermal Issue", high, medium,
    "Check battery health, charging circuit, and overheating causes. Replace battery if swelling or fast drain is found.").
fault_info(phone_physical_display_power_issue, phone, "Physical Display and Power Issue", high, high,
    "Inspect display assembly and battery connection. Replace damaged screen parts after checking power delivery.").
fault_info(phone_liquid_display_issue, phone, "Liquid Display Damage", critical, high,
    "Power off immediately. Do not charge. Clean the board and inspect the display connector and panel.").
fault_info(phone_battery_charging_issue, phone, "Phone Battery and Charging Issue", high, medium,
    "Check the charging port, cable, battery health, and charging circuit.").
fault_info(phone_overheating_battery_issue, phone, "Phone Overheating Battery Issue", high, medium,
    "Check battery health, background apps, and charging behavior. Replace battery if swollen or weak.").
fault_info(phone_screen_touch_issue, phone, "Screen and Touch Issue", high, high,
    "Inspect the display connector and touch panel. Replace display assembly if touch or image is missing.").
fault_info(phone_software_performance_issue, phone, "Software Performance Issue", medium, low,
    "Clear storage, remove unused apps, update software, and restart the phone.").
fault_info(phone_charging_ic_issue, phone, "Charging IC or Battery Circuit Issue", high, medium,
    "Check the charging port and cable first. If overheating or drain continues, inspect charging IC and battery circuit.").
fault_info(phone_camera_software_issue, phone, "Camera Software or Storage Issue", medium, low,
    "Check camera permissions, free storage, clear camera app cache, and update the phone.").
fault_info(phone_audio_software_issue, phone, "Audio Software or Speaker Issue", medium, low,
    "Check volume settings, clean the speaker grill, restart the phone, and test audio in another app.").
fault_info(phone_network_software_issue, phone, "Network Settings or Wi-Fi Issue", medium, low,
    "Reset network settings, update software, and test Wi-Fi on another network.").
fault_info(phone_firmware_storage_issue, phone, "Firmware and Storage Issue", critical, medium,
    "Free storage if possible, then repair firmware or update the system software.").
