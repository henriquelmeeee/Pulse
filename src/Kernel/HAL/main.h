#pragma once

GDT gdt;
ACPI acpi;
PIC pic;
APIC apic;

namespace HAL {
    bool Initialize();
}