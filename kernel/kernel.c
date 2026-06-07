#include "../drivers/screen.h"
#include "../drivers/keyboard.h"
#include "../cpu/isr.h"

void kernel_main()
{
    isr_install();
    clear_screen();

/*-----------------------------------*/
 
    
    print("Nikola Jokic");
    
    print_char('S', 13, 0, 0x04);
    
    print("\n");
    
    
/*-----------------------------------*/
    
    
    keyboard_install();
    print("Keyboard ready\n");
   
    while(1) {}
}
