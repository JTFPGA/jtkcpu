assign { 
        we, 
        waituz, 
        wait16, 
        pul_go, 
        psh_go, 
        pshpc, 
        pshcc, 
        pshall, 
        set_pc_xnz_branch, 
        set_pc_bnz_branch, 
        set_pc_vector, 
        set_pc_puls, 
        set_pc_branch, 
        set_opn0_regs, 
        set_opn0_d, 
        set_opn0_a, 
        ni, 
        mem16, 
        incx, 
        ifirq_pulall, 
        iffirq_pulpc, 
        iffirq_pulcc, 
        set_i, 
        set_f, 
        extsgn, 
        set_e, 
        clr_e, 
        decx, 
        decu, 
        decb, 
        adry, 
        adrx, 
        adridx, ???
        } = ucode;

always @* begin
    case( addr )
        000: ucode = 34'h20000;    // NOPE
        001: ucode = 34'h001;
        002: ucode = 34'h20000;
        003: ucode = 34'h001;
        004: ucode = 34'h100001;
        005: ucode = 34'h20000;
        006: ucode = 34'h001;
        007: ucode = 34'h100001;
        008: ucode = 34'h20000;
        009: ucode = 34'h001;
        00A: ucode = 34'h100001;
        00B: ucode = 34'h20000;
        00C: ucode = 34'h001;
        00D: ucode = 34'h20001;
        00E: ucode = 34'h001;
        00F: ucode = 34'h200020000;
        010: ucode = 34'h220200;    // SBRANCH
        020: ucode = 34'h80000000;    // LBRANCH
        021: ucode = 34'h220000;
        030: ucode = 34'h2020040;    // LOOPX
        040: ucode = 34'h1020010;    // LOOPB
        050: ucode = 34'h008;    // MOVE
        051: ucode = 34'h200008025;
        052: ucode = 34'h20000;
        060: ucode = 34'h008;    // BMOVE
        061: ucode = 34'h300008025;
        062: ucode = 34'h20000;
        070: ucode = 34'h300048024;    // BSETA
        071: ucode = 34'h20000;
        080: ucode = 34'h300098024;    // BSETD
        081: ucode = 34'h20000;
        090: ucode = 34'h210000;    // JUMP
        091: ucode = 34'h20000;
        0A0: ucode = 34'h230000;    // JMSR
        0B0: ucode = 34'h7000;    // RTIT
        0B1: ucode = 34'h20000;
        0C0: ucode = 34'h420000;    // RTSR
        0D0: ucode = 34'h20000000;    // PSH
        0D1: ucode = 34'h200100001;
        0D2: ucode = 34'h20000;
        0E0: ucode = 34'h40000000;    // PUL
        0E1: ucode = 34'h200100001;
        0E2: ucode = 34'h20000;
        0F0: ucode = 34'h18800C80;    // FIRQ
        0F1: ucode = 34'h20000;
        100: ucode = 34'h4800900;    // IRQ
        101: ucode = 34'h20000;
        110: ucode = 34'h4800D00;    // NMI
        111: ucode = 34'h20000;
        120: ucode = 34'h001;    // SETLINES
        130: ucode = 34'h200120002;    // STORE8
        140: ucode = 34'h200110002;    // STORE16
        141: ucode = 34'h20000;
        default: ucode = 0;
    endcase
end

