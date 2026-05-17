#include "limine.h"
#include "print.h"

extern "C" limine_framebuffer_request framebuffer_request;

static void hang() {
    for (;;) {
        asm volatile("cli; hlt");
    }
}

extern "C" void kernel_main() {
    if (!framebuffer_request.response) hang();
    if (framebuffer_request.response->framebuffer_count == 0) hang();

    limine_framebuffer *fb = framebuffer_request.response->framebuffers[0];

    Framebuffer print_fb{
        .pixels = static_cast<uint32_t*>(fb->address),
        .width = fb->width,
        .height = fb->height,
        .pitch_bytes = fb->pitch,
    };

    print_init(print_fb);
    print_set_color(0x00FFFFFF, 0x00000000);
    print_clear();
    print_str("Hello, kernel!\n");
    print_str("If you can read this, C++ is running on bare metal.\n");
    print_str("\n");
    print_str("Next steps: GDT, IDT, interrupts, memory management...\n");

    hang();
}
