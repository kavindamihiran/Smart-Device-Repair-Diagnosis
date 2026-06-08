% =========================================================
% Module 3: Diagnostic Rule Base
% =========================================================
% fault_symptoms(Device, FaultAtom, RequiredSymptoms).
%
% Each rule states which symptoms usually indicate a fault.

:- multifile fault_symptoms/3.

fault_symptoms(laptop, battery_failure,
    [battery_drain, random_shutdown, no_power]).
fault_symptoms(laptop, charger_or_port_issue,
    [no_charging]).
fault_symptoms(laptop, cooling_problem,
    [overheating, loud_fan, random_shutdown, slow_performance]).
fault_symptoms(laptop, display_damage,
    [black_screen, display_flicker]).
fault_symptoms(laptop, storage_failure,
    [boot_failure, clicking_sound, random_shutdown, blue_screen]).
fault_symptoms(laptop, malware_infection,
    [slow_performance, virus_popups, blue_screen]).
fault_symptoms(laptop, ram_or_os_crash,
    [blue_screen, random_shutdown, boot_failure]).
fault_symptoms(laptop, keyboard_fault,
    [keyboard_not_working]).
fault_symptoms(laptop, wifi_adapter_fault,
    [wifi_not_working]).
fault_symptoms(laptop, power_thermal_issue,
    [battery_drain, overheating, loud_fan, random_shutdown]).
fault_symptoms(laptop, thermal_boot_instability,
    [overheating, loud_fan, boot_failure, blue_screen]).
fault_symptoms(laptop, storage_or_system_crash,
    [clicking_sound, random_shutdown, blue_screen, boot_failure]).
fault_symptoms(laptop, battery_charging_issue,
    [battery_drain, no_charging, random_shutdown]).
fault_symptoms(laptop, motherboard_power_issue,
    [no_power, no_charging, random_shutdown]).
fault_symptoms(laptop, display_or_graphics_issue,
    [black_screen, display_flicker, blue_screen]).
fault_symptoms(laptop, system_performance_issue,
    [slow_performance, boot_failure, virus_popups]).
fault_symptoms(laptop, os_boot_problem,
    [boot_failure, blue_screen, slow_performance]).
fault_symptoms(laptop, software_crash_or_malware,
    [virus_popups, slow_performance, blue_screen]).
fault_symptoms(laptop, power_display_startup_issue,
    [no_power, black_screen, no_charging]).

fault_symptoms(phone, phone_battery_failure,
    [battery_drain, random_shutdown, no_power]).
fault_symptoms(phone, phone_charging_port_issue,
    [no_charging]).
fault_symptoms(phone, phone_display_damage,
    [cracked_screen, black_screen, touch_not_working]).
fault_symptoms(phone, phone_storage_overload,
    [storage_full, slow_performance]).
fault_symptoms(phone, phone_water_damage,
    [water_damage, no_power, no_charging]).
fault_symptoms(phone, phone_camera_fault,
    [camera_not_working]).
fault_symptoms(phone, phone_speaker_fault,
    [speaker_not_working]).
fault_symptoms(phone, phone_network_fault,
    [wifi_not_working]).
fault_symptoms(phone, phone_boot_loop_fault,
    [boot_loop, random_shutdown]).
fault_symptoms(phone, phone_power_thermal_issue,
    [battery_drain, overheating, random_shutdown, no_power]).
fault_symptoms(phone, phone_physical_display_power_issue,
    [cracked_screen, no_power, battery_drain, random_shutdown]).
fault_symptoms(phone, phone_liquid_display_issue,
    [water_damage, no_charging, no_power, black_screen, touch_not_working]).
fault_symptoms(phone, phone_battery_charging_issue,
    [battery_drain, no_charging, random_shutdown]).
fault_symptoms(phone, phone_overheating_battery_issue,
    [battery_drain, overheating, random_shutdown]).
fault_symptoms(phone, phone_screen_touch_issue,
    [black_screen, touch_not_working, cracked_screen]).
fault_symptoms(phone, phone_software_performance_issue,
    [slow_performance, storage_full, boot_loop]).
fault_symptoms(phone, phone_charging_ic_issue,
    [no_charging, overheating, battery_drain]).
fault_symptoms(phone, phone_camera_software_issue,
    [camera_not_working, storage_full, slow_performance]).
fault_symptoms(phone, phone_audio_software_issue,
    [speaker_not_working, slow_performance]).
fault_symptoms(phone, phone_network_software_issue,
    [wifi_not_working, slow_performance]).
fault_symptoms(phone, phone_firmware_storage_issue,
    [boot_loop, storage_full, slow_performance]).
