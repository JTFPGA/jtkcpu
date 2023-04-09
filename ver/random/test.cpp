#include <cstdio>
#include <cstring>
#include <cstdlib>
#include "UUT.h"
#include "ops.h"

#include "verilated_vcd_c.h"

const int ROM_START=0x6000;

class Emu {
    enum { CC_H=0x20, CC_N=8, CC_Z=4, CC_V=2, CC_C=1 };
    UUT &uut;
    int get_exg( int opnd ) {
        switch(opnd & 0x07)
        {
            case 0: return ((int)a)&0xff;
            case 1: return ((int)b)&0xff;
            case 2: return x;
            case 3: return y;
            case 4: return s;
            case 5: return u;
        }
        printf("Unexpected operand for EXG\n");
        return -1;
    }
    void set_nz( int8_t &r ) {
        if( r==0 ) cc |= CC_Z; else cc &= ~CC_Z;
        if( r<0  ) cc |= CC_N; else cc &= ~CC_N;
    }
    void set_nz16( int16_t r ) {
        if( r==0 ) cc |= CC_Z; else cc &= ~CC_Z;
        if( r<0  ) cc |= CC_N; else cc &= ~CC_N;
    }
    void and8( int8_t &r, int8_t opnd ) {
        r   &= opnd;
        set_nz(r);
        cc &= ~CC_V;
    }
    void bit8( int8_t r, int8_t opnd ) {
        r   &= opnd;
        set_nz(r);
        cc &= ~CC_V;
    }
    void eor( int8_t &r, int8_t opnd ) {
        r   ^= opnd;
        set_nz(r);
        cc &= ~CC_V;
    }
    void or8( int8_t &r, int8_t opnd ) {
        r   |= opnd;
        set_nz(r);
        cc &= ~CC_V;
    }
    void add( int8_t &r, int8_t opnd, int8_t cin ) {
        int rxn = r;
        int rop = opnd;
        if( ((r&0xf)+(opnd&0xf)+cin)>0xf ) cc |= CC_H; else cc &= ~CC_H;
        if( ((rxn&0xff) + (rop&0xff)+cin)&0x100 ) cc |= CC_C; else cc &= ~CC_C;
        r   += opnd + cin;  // limited sum
        rxn += rop  + cin; // more bits
        set_nz(r);
        if( (rxn<0 && r>=0) || (rxn>=0 && r<0) ) cc |= CC_V; else cc &= ~CC_V;
    }
    void cmp( int8_t r, int8_t opnd ) {
        int rxn = r;
        int rop = opnd;
        if( ((rxn&0xff) - (rop&0xff))&0x100 ) cc |= CC_C; else cc &= ~CC_C;
        r   -= opnd;  // limited sum
        rxn -= rop; // more bits
        set_nz(r);
        if( (rxn<0 && r>=0) || (rxn>=0 && r<0) ) cc |= CC_V; else cc &= ~CC_V;
    }
    void sub( int8_t &r, int8_t opnd, int8_t cin ) {
        int rxn = r;
        int rop = opnd;
        if( ((rxn&0xff) - (rop&0xff)-cin)&0x100 ) cc |= CC_C; else cc &= ~CC_C;
        r   -= opnd + cin;  // limited sum
        rxn -= rop  + cin; // more bits
        set_nz(r);
        if( (rxn<0 && r>=0) || (rxn>=0 && r<0) ) cc |= CC_V; else cc &= ~CC_V;
    }
    void ld( int8_t &r, int8_t opnd ) {
        r = opnd;  // limited sum
        set_nz(r);
        cc &= ~CC_V;
    }
    void ld16( int16_t &r, int& addr ) {
        r = (rom[addr++]<<8)|rom[addr++];
        set_nz16(r);
        cc &= ~CC_V;
    }
    void exg( int8_t opnd ) {
        unsigned left  = get_exg(opnd>>4);
        unsigned right = get_exg(opnd);
        switch( (opnd>>4)&7 ) {
        case 0: a = right; break;
        case 1: b = right; break;
        case 2: x = right; break;
        case 3: y = right; break;
        case 4: s = right; break;
        case 5: u = right; break;
        }
        switch( opnd&7 ) {
        case 0: a = left; break;
        case 1: b = left; break;
        case 2: x = left; break;
        case 3: y = left; break;
        case 4: s = left; break;
        case 5: u = left; break;
        }
    }
    void tfr( int8_t opnd ) {
        unsigned right = get_exg(opnd);
        switch( (opnd>>4)&7 ) {
        case 0: a = right; break;
        case 1: b = right; break;
        case 2: x = right; break;
        case 3: y = right; break;
        case 4: s = right; break;
        case 5: u = right; break;
        }
    }
public:
    const int8_t *rom;
    int8_t a, b;
    uint8_t cc;
    int16_t x,y,u,s;
    Emu(UUT &_uut) : uut(_uut) {
        a=b=0; cc=0x50;
        x = y = u = s;
    }
    bool Cmp(int addr) {
        addr -= ROM_START;
        char op = rom[addr++];
        switch(op) {
        case LDA : ld(a, rom[addr++]); break;
        case LDB : ld(b, rom[addr++]); break;
        case ADDA: add( a, rom[addr++], 0 ); break;
        case ADDB: add( b, rom[addr++], 0 ); break;
        case ADCA: add( a, rom[addr++], cc&1 ); break;
        case ADCB: add( b, rom[addr++], cc&1 ); break;
        case SUBA: sub( a, rom[addr++], 0 ); break;
        case SUBB: sub( b, rom[addr++], 0 ); break;
        case CMPA: cmp( a, rom[addr++] ); break;
        case CMPB: cmp( b, rom[addr++] ); break;
        case SBCA: sub( a, rom[addr++], cc&1 ); break;
        case SBCB: sub( b, rom[addr++], cc&1 ); break;
        case ANDA: and8( a, rom[addr++] ); break;
        case ANDB: and8( b, rom[addr++] ); break;
        case BITA: bit8( a, rom[addr++] ); break;
        case BITB: bit8( b, rom[addr++] ); break;
        case EORA: eor( a, rom[addr++] ); break;
        case EORB: eor( b, rom[addr++] ); break;
        case ORA:  or8( a, rom[addr++] ); break;
        case ORB:  or8( b, rom[addr++] ); break;
        case ANDCC: cc &= rom[addr++]; break;
        case EXG: exg( rom[addr++] ); break;
        case TFR: tfr( rom[addr++] ); break;
        case LDX: ld16( x, addr ); break;
        case LDY: ld16( y, addr ); break;
        case LDU: ld16( u, addr ); break;
        case LDS: ld16( s, addr ); break;
        }
        bool good = true;
        good = good && (a == (char)(uut.a));
        good = good && (b == (char)(uut.b));
        good = good && (cc == (char)(uut.cc));
        good = good && ( (x&0xffff) == uut.x);
        good = good && ( (y&0xffff) == uut.y);
        good = good && ( (s&0xffff) == uut.s);
        good = good && ( (u&0xffff) == uut.u);
        return good;
    }
    void Dump(int addr) {
        printf("Diverged at %X\n",addr);
        printf("        EMU -- SIM\n");
        printf("a  =   %02X --   %02X\n", ((int)a)&0xff, uut.a );
        printf("b  =   %02X --   %02X\n", ((int)b)&0xff, uut.b );
        printf("x  = %04X   -- %04X\n", ((int)x)&0xffff, uut.x );
        printf("y  = %04X   -- %04X\n", ((int)y)&0xffff, uut.y );
        printf("u  = %04X   -- %04X\n", ((int)u)&0xffff, uut.u );
        printf("s  = %04X   -- %04X\n", ((int)s)&0xffff, uut.s );
        printf("cc = %02X   -- %02X\n", ((int)cc)&0xff, uut.cc );
        printf("ROM... ");
        addr -= ROM_START;
        for( int k=0; k<4; k++ ) {
            printf("%02X ", ((int)rom[addr+k])&0xff);
        }
        putchar('\n');
    }
};

class Test {
    UUT &uut;
    vluint64_t simtime;
    vluint64_t semi_period;
    VerilatedVcdC* tracer;
    Emu emu;
    bool trace;

    int8_t *rom;

    void random_op(int &k, int maxbytes ) {
        if( maxbytes<=0 ) return;
        char aux;
        while(true) {
            int op = rand()&0xff;
            switch( op ) {
            case LDA : case LDB :
            case ADDA: case ADDB:
            case ADCA: case ADCB:
            case SUBA: case SUBB:
            case SBCA: case SBCB:
            case ANDA: case ANDB:
            case BITA: case BITB:
            case EORA: case EORB:
            case ORA:  case ORB:
            case CMPA: case CMPB:
            case ANDCC:
                if( maxbytes<2 ) break;
                rom[k++] = (char)op;
                rom[k++] = (char)rand();
                return;
            case LDX: case LDY:
            case LDU: case LDS:
                if( maxbytes<3 ) break;
                rom[k++] = (char)op;
                rom[k++] = (char)rand();
                rom[k++] = (char)rand();
                return;
            case EXG: case TFR:
                if( maxbytes<2 ) break;
                rom[k++] = (char)op;
                do{
                    aux=rand();
                }while((aux&0x0f)>0x05 || (aux&0xf0)>0x50);
                rom[k++] = aux;
                return;
            }
        }
    }
    void make_rom() {
        const int ROM_LEN=0xA000;
        rom = new int8_t[ROM_LEN];
        memset( rom, 0, ROM_LEN );
        for(int k=0;k<ROM_LEN-16;) {
            random_op( k, 2 );
        }
        // Reset vector
        rom[ROM_LEN-2]=(0x10000-ROM_LEN)>>8;
        rom[ROM_LEN-1]=(0x10000-ROM_LEN)&0xFF;
    }
public:
    Test( UUT& _uut, bool _trace ) : emu(_uut), uut(_uut), trace(_trace) {
        simtime=0;
        semi_period=5;
        make_rom();
        if( trace ) {
            Verilated::traceEverOn(true);
            tracer = new VerilatedVcdC;
            uut.trace( tracer, 99 );
            tracer->open("test.vcd");
            fputs("Verilator will dump to test.vcd\n",stderr);
        } else {
            tracer = nullptr;
        }
        emu.rom = rom;
        Reset();
    }
    ~Test() {
        delete tracer;
        tracer=nullptr;
        delete []rom;
        rom=nullptr;
    }
    void Reset() {
        uut.rst=0;
        uut.clk=0;
        uut.cen2=1;
        uut.halt=0;
        uut.nmi_n = uut.irq_n = uut.firq_n = 1;
        uut.dtack = 1;
        Clock(10);
        uut.rst=1;
        Clock(10);
        uut.rst=0;
    }
    bool Clock(unsigned n) {
        static int is_opl=0, nx_op=0;
        n<<=1;
        while( n-- ) {
            simtime += semi_period;
            uut.clk = n&1;
            uut.eval();
            tracer->dump(simtime);
            if( uut.clk==0 ) {  // set inputs
                uut.cen2 = 1-uut.cen2;
                uut.din = uut.addr>=0x6000 ? rom[uut.addr-0x6000] : 0;
            } else {
                if( uut.is_op && !is_opl ) {
                    if(nx_op!=0) {
                        if( !emu.Cmp(nx_op) ) {
                            emu.Dump(nx_op);
                            return false;
                        }
                    }
                    nx_op = uut.addr;
                    if( uut.addr>0xff00 ) return false; // do not sim passed here
                }
                is_opl = uut.is_op;
            }
        }
        return true;
    }
};

int main() {
    srand(1);

    UUT uut;
    Test test(uut, true);
    while( test.Clock(100) );

    return 0;
}