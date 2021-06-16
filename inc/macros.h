#ifndef MACROS_H
#define MACROS_H

#define SET_BIT(REG, BIT)     			((REG) |= (BIT))
#define TOG_BIT(REG, BIT) 			    ((REG) ^= (BIT))
#define RST_BIT(REG, BIT)               ((REG) &= ~(BIT))
#define GET_BIT(REG, BIT)               ((REG) & (BIT))

#define UNUSED(X) (void)X

#endif /* MACROS_H */
