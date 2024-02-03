#include "main.h"

bool compatible_with_apic = false;

namespace HAL {
    bool Initialize() {
        // Iterate over 0x500 (memory map)
        // Create GDT, ACPI, PIC object
        // checks if its compatible to APIC
    }
}