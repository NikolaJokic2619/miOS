#include "../drivers/screen.h"
#include "../cpu/idt.h"
#include "../cpu/isr.h"

void kernel_main()
{
    clear_screen();
/*-----------------------------------*/

    idt_init(); 
    isr_init();   

/*-----------------------------------*/
    
    print("Nikola Jokic");
    
    print_char('S', 13, 0, 0x04);
    
    print("\n");
    
    
/*-----------------------------------*/
    __asm__ volatile ("sti");
    print("IDT loaded. Interrupts enabled.\n");
   
    int x = 0;
    print("test\n");
    int y = 1/x;
    print("interrupts do not work!!!");   
    
/*-----------------------------------*/

                    
    while(1) {}
}
