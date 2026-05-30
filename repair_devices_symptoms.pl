% =========================================================
% Module 1: Devices and Symptoms
% =========================================================
% device/1 lists supported device types.
% symptom/3 maps each internal symptom atom to a readable label.

device(laptop).
device(phone).

% symptom(Device, SymptomAtom, HumanReadableLabel).

symptom(laptop, no_power, "Does not power on").
symptom(laptop, no_charging, "Does not charge").
symptom(laptop, battery_drain, "Battery drains quickly").
symptom(laptop, random_shutdown, "Random shutdown").
symptom(laptop, overheating, "Overheating").
symptom(laptop, loud_fan, "Fan is very loud").
symptom(laptop, black_screen, "Black screen").
symptom(laptop, display_flicker, "Display flickering").
symptom(laptop, slow_performance, "Slow performance").
symptom(laptop, boot_failure, "Boot failure").
symptom(laptop, clicking_sound, "Clicking sound from storage").
symptom(laptop, keyboard_not_working, "Keyboard not working").
symptom(laptop, wifi_not_working, "Wi-Fi not working").
symptom(laptop, virus_popups, "Unwanted popups / suspicious apps").
symptom(laptop, blue_screen, "Blue screen / system crash").

symptom(phone, no_power, "Does not power on").
symptom(phone, no_charging, "Does not charge").
symptom(phone, battery_drain, "Battery drains quickly").
symptom(phone, random_shutdown, "Random shutdown").
symptom(phone, overheating, "Overheating").
symptom(phone, cracked_screen, "Cracked screen").
symptom(phone, black_screen, "Black screen").
symptom(phone, touch_not_working, "Touch not working").
symptom(phone, slow_performance, "Slow performance").
symptom(phone, storage_full, "Storage full").
symptom(phone, wifi_not_working, "Wi-Fi not working").
symptom(phone, camera_not_working, "Camera not working").
symptom(phone, speaker_not_working, "Speaker not working").
symptom(phone, water_damage, "Water damage").
symptom(phone, boot_loop, "Phone stuck in boot loop").
