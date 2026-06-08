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
   
    __asm__ volatile ("div %0" : : "r"(0));
    print("THIS SHOULD NEVER PRINT\n");  
    
/*-----------------------------------*/

                    
    while(1) {}
}
