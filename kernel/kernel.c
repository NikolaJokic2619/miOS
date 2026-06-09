#include "../drivers/screen.h"
#include "../cpu/idt.h"
#include "../cpu/isr.h"
#include "../cpu/pic.h"
#include "../cpu/irq.h"
#include "../cpu/timer.h"
#include "../drivers/keyboard.h"

void kernel_main()
{
    clear_screen();
/*-----------------------------------*/

    idt_init(); 
    isr_init();   
    PIC_remap(0x20, 0x28);
    irq_init();
    timer_init(100);
    keyboard_init();
/*-----------------------------------*/
    
    print("Nikola Jokic");
    
    print_char('S', 13, 0, 0x04);
    
    print("\n");
    
/*-----------------------------------*/
   
    //__asm__ volatile ("div %0" : : "r"(0));
    //print("THIS SHOULD NEVER PRINT\n");  
    
/*-----------------------------------*/

    __asm__ volatile("sti");
    
/*-----------------------------------*/

    print("waiting 5 seconds...\n");
    timer_sleep(5);
    print("done!\n");

/*-----------------------------------*/

                    
    while(1) {}
}
