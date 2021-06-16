/*
	Sample main for STM32L4 target.
	The default code blink a LED on PB3 (Nucleo-32)
*/

#include "stm32l4xx.h"
#include "main.h"
#include "macros.h"

int main(void)
{
	// Enable GPIO clock
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOBEN;

	// Reset GPIO mode
	GPIOB->MODER &= ~GPIO_MODER_MODE3_Msk;
	// Set bit 0 of mode -> 0x01 (Output)
	GPIOB->MODER |= GPIO_MODER_MODE3_0;

	while (1)
	{
		// Toggle GPIO
		TOG_BIT(GPIOB->ODR, GPIO_ODR_OD3);

		// Wait for some time
		for (unsigned int i = 0; i < 500000; i++)
		{
			__NOP();
		}
	}
	return 0;
}