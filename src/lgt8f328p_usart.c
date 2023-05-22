/**********************************************************************************
** API implementation for USART module
***********************************************************************************
*/

#include <avr/io.h>
#include <stdint.h>

#include "lgt8f328p_spec.h"
#include "lgt8f328p_conf.h"

/**********************************************************************************
*** 						  	EXPORTED FUNCTIONS								*** 													
**********************************************************************************/

// ----------------------------------------------------------------------
// public: usart module initialization
// ----------------------------------------------------------------------
void usartInit(void)
{
	UCSR0A 	= (USART_MPCM0 << MPCM0) | (USART_U2X0 << U2X0);

	UCSR0C = (USART_UMSEL0 << UMSEL00 ) | (USART_UPM0 << UPM00) | (USART_USBS0 << USBS0) |\
			((USART_UCSZ0 & 3) << UCSZ00 ) | (USART_UCPOL0 << UCPOL0);

	UCSR0B = (USART_RXEN << RXEN0) | (USART_TXEN << TXEN0) | (USART_UCSZ0 & 0x4) |\
			(USART_RXC << RXCIE0) | (USART_TXC << TXCIE0) | (USART_UDRE << UDRIE0);
	
	UBRR0H = (USART_UBRR >> 8) & 0xff;
	UBRR0L = USART_UBRR & 0xff;
    //UBRR0H = (USART_UBRR >> 8) & 0x00;
    //UBRR0L = USART_UBRR & 0x67;
}

// ----------------------------------------------------------------------
// public: send a char
// ----------------------------------------------------------------------
void usartPutChar(uint8_t u8Char)
{
	while(!(UCSR0A & (1 << UDRE0)));

	UDR0 = u8Char;
}

// ----------------------------------------------------------------------
// public: get and return a char
// ----------------------------------------------------------------------
uint8_t usartGetChar()
{
	while(!(UCSR0A & (1 << RXC0)));

	return (uint8_t)UDR0;
}

// ----------------------------------------------------------------------
// public: send a string
// ----------------------------------------------------------------------
void usartPutStr(char *pStr)
{
	char *p = pStr;

	while(*p)
	{
		usartPutChar(*p++);
	}
}

/**********************************************************************************
*** 									EOF 									*** 													
**********************************************************************************/
