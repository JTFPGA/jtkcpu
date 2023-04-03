localparam UCODE_DW = 59;
localparam OPCAT_AW = 6;
localparam UCODE_AW = OPCAT_AW+3;
localparam [OPCAT_AW-1:0] 
        PARSE_IDX        = 'o0,
        IDX_R            = 'o1,
        IDX_RINC         = 'o2,
        IDX_RINC2        = 'o3,
        IDX_RDEC         = 'o4,
        IDX_RDEC2        = 'o5,
        IDX_OFFSET8      = 'o6,
        IDX_OFFSET16     = 'o7,
        IDX_IND          = 'o10,
        IDX_EXT          = 'o11,
        IDX_DP           = 'o12,
        IDX_ACC          = 'o13,
        SINGLE_ALU       = 'o14,
        CMP8             = 'o15,
        CMP8_IDX         = 'o16,
        SINGLE_ALU_16    = 'o17,
        CMP16            = 'o20,
        CMP16_IDX        = 'o21,
        SINGLE_A_INH     = 'o22,
        SINGLE_B_INH     = 'o23,
        SINGLE_ALU_INH16 = 'o24,
        SINGLE_ALU_IDX   = 'o25,
        SINGLE_ALU_IDX16 = 'o26,
        MULTI_ALU        = 'o27,
        MEM_ALU_IDX      = 'o30,
        MULTI_ALU_INH    = 'o31,
        MULTI_ALU_IDX    = 'o32,
        WMEM_ALU         = 'o33,
        MULTIPLY         = 'o34,
        LMULTIPLY        = 'o35,
        LOOPX            = 'o36,
        LOOPB            = 'o37,
        MOVE             = 'o40,
        BMOVE            = 'o41,
        BSETA            = 'o42,
        BSETD            = 'o43,
        STORE8           = 'o44,
        STORE16          = 'o45,
        LEA              = 'o46,
        SETLNS           = 'o47,
        SETLNS_IDX       = 'o50,
        EXCHANGE         = 'o51,
        TRANSFER         = 'o52,
        NOPE             = 'o53,
        SBRANCH          = 'o54,
        SBSR             = 'o55,
        BSRL             = 'o56,
        LBRANCH          = 'o57,
        JUMP             = 'o60,
        JMSR             = 'o61,
        RTIT             = 'o62,
        RTSR             = 'o63,
        PSH              = 'o64,
        PUL              = 'o65,
        RESET            = 'o66,
        FIRQ             = 'o67,
        IRQ              = 'o70,
        NMI              = 'o71,
        BUSERROR         = 'o72;

assign { 
        we, 
        up_tfr, 
        up_move, 
        up_lmul, 
        up_lines, 
        up_lea, 
        up_ldb, 
        up_lda, 
        up_ld8, 
        up_ld16, 
        up_exg, 
        up_data, 
        up_cc, 
        up_ab, 
        uc_loop, 
        rti_other, 
        rti_cc, 
        pul_go, 
        psh_pc, 
        psh_go, 
        psh_cc, 
        psh_all, 
        pc_jmp, 
        set_pc_branch8, 
        set_pc_branch16, 
        set_opn0_x, 
        set_opn0_regs, 
        set_opn0_mem, 
        set_opn0_b, 
        opd, 
        niuz, 
        ni, 
        memhi, 
        int_en, 
        incx, 
        idx_ret, 
        idx_pre, 
        set_idx_post, 
        idx_jmp, 
        idx_ind, 
        idx_en, 
        idx_dp, 
        idx_adv, 
        set_idx_acc, 
        idx_8, 
        idx_16, 
        set_idxw, 
        set_i, 
        set_f, 
        set_e, 
        clr_e, 
        decx, 
        decu, 
        decb, 
        data2addr, 
        buserror, 
        branch_bnz, 
        addry, 
        addrx
    } = ucode;

always @(posedge clk) if(cen) begin
    case( addr )
        9'o000: ucode <= 59'h20000000;    // PARSE_IDX
        9'o001: ucode <= 59'h100000;
        9'o011: ucode <= 59'h80000;
        9'o020: ucode <= 59'h200000;    // IDX_RINC
        9'o021: ucode <= 59'h80000;
        9'o030: ucode <= 59'h201000;    // IDX_RINC2
        9'o031: ucode <= 59'h80000;
        9'o040: ucode <= 59'h400000;    // IDX_RDEC
        9'o041: ucode <= 59'h80000;
        9'o050: ucode <= 59'h401000;    // IDX_RDEC2
        9'o051: ucode <= 59'h80000;
        9'o060: ucode <= 59'h20000000;    // IDX_OFFSET8
        9'o061: ucode <= 59'h84000;
        9'o070: ucode <= 59'h24000000;    // IDX_OFFSET16
        9'o071: ucode <= 59'h20000000;
        9'o072: ucode <= 59'h82000;
        9'o100: ucode <= 59'h4040000;    // IDX_IND
        9'o101: ucode <= 59'h50000;
        9'o102: ucode <= 59'h800010;
        9'o110: ucode <= 59'h24000000;    // IDX_EXT
        9'o111: ucode <= 59'h20000000;
        9'o112: ucode <= 59'h80010;
        9'o120: ucode <= 59'h20000000;    // IDX_DP
        9'o121: ucode <= 59'hA0000;
        9'o131: ucode <= 59'h88000;
        9'o140: ucode <= 59'h20000000;    // SINGLE_ALU
        9'o141: ucode <= 59'h4400100000000;
        9'o142: ucode <= 59'h8000000;
        9'o150: ucode <= 59'h20000000;    // CMP8
        9'o151: ucode <= 59'h400100000000;
        9'o152: ucode <= 59'h8000000;
        9'o160: ucode <= 59'h40000;    // CMP8_IDX
        9'o161: ucode <= 59'h400100000000;
        9'o162: ucode <= 59'h8000000;
        9'o170: ucode <= 59'h24000000;    // SINGLE_ALU_16
        9'o171: ucode <= 59'h20000000;
        9'o172: ucode <= 59'h2400100000000;
        9'o173: ucode <= 59'h8000000;
        9'o200: ucode <= 59'h24000000;    // CMP16
        9'o201: ucode <= 59'h20000000;
        9'o202: ucode <= 59'h400100000000;
        9'o203: ucode <= 59'h8000000;
        9'o210: ucode <= 59'h4040000;    // CMP16_IDX
        9'o211: ucode <= 59'h50000;
        9'o212: ucode <= 59'h400100000000;
        9'o213: ucode <= 59'h8000000;
        9'o220: ucode <= 59'h8400100000000;    // SINGLE_A_INH
        9'o221: ucode <= 59'h8000000;
        9'o230: ucode <= 59'h10400100000000;    // SINGLE_B_INH
        9'o231: ucode <= 59'h8000000;
        9'o240: ucode <= 59'h600100000000;    // SINGLE_ALU_INH16
        9'o241: ucode <= 59'h8000000;
        9'o250: ucode <= 59'h40000;    // SINGLE_ALU_IDX
        9'o251: ucode <= 59'h4400100000000;
        9'o252: ucode <= 59'h8000000;
        9'o260: ucode <= 59'h4040000;    // SINGLE_ALU_IDX16
        9'o261: ucode <= 59'h50000;
        9'o262: ucode <= 59'h2400100000000;
        9'o263: ucode <= 59'h8000000;
        9'o270: ucode <= 59'h20000000;    // MULTI_ALU
        9'o271: ucode <= 59'h400100000000;
        9'o272: ucode <= 59'h8000000;
        9'o300: ucode <= 59'h40000;    // MEM_ALU_IDX
        9'o301: ucode <= 59'h400000000040000;
        9'o302: ucode <= 59'h8000000;
        9'o310: ucode <= 59'h20000000;    // MULTI_ALU_INH
        9'o311: ucode <= 59'h400100000000;
        9'o312: ucode <= 59'h8000000;
        9'o320: ucode <= 59'h40000;    // MULTI_ALU_IDX
        9'o321: ucode <= 59'h400100000000;
        9'o322: ucode <= 59'h8000000;
        9'o330: ucode <= 59'h40000;    // WMEM_ALU
        9'o331: ucode <= 59'h800080000000;
        9'o332: ucode <= 59'h400000000040000;
        9'o333: ucode <= 59'h8000000;
        9'o345: ucode <= 59'h600000000000;
        9'o346: ucode <= 59'h8000000;
        9'o355: ucode <= 59'h80000000000000;
        9'o356: ucode <= 59'h8000000;
        9'o360: ucode <= 59'h20000000;    // LOOPX
        9'o361: ucode <= 59'h400200000080;
        9'o362: ucode <= 59'h004;
        9'o363: ucode <= 59'h8000000;
        9'o370: ucode <= 59'h20000000;    // LOOPB
        9'o371: ucode <= 59'h400040000020;
        9'o372: ucode <= 59'h004;
        9'o373: ucode <= 59'h8000000;
        9'o400: ucode <= 59'h002;    // MOVE
        9'o401: ucode <= 59'h500000000000001;
        9'o402: ucode <= 59'h8000000;
        9'o410: ucode <= 59'h10000000;    // BMOVE
        9'o412: ucode <= 59'h002;
        9'o413: ucode <= 59'h500000000000001;
        9'o414: ucode <= 59'h100000000000;
        9'o420: ucode <= 59'h10000000;    // BSETA
        9'o422: ucode <= 59'h400000001000041;
        9'o423: ucode <= 59'h100000000000;
        9'o430: ucode <= 59'h10000000;    // BSETD
        9'o432: ucode <= 59'h400000001000041;
        9'o433: ucode <= 59'h400000001000001;
        9'o434: ucode <= 59'h100000000000;
        9'o440: ucode <= 59'h400000100040000;    // STORE8
        9'o441: ucode <= 59'h8000000;
        9'o450: ucode <= 59'h400000104040000;    // STORE16
        9'o451: ucode <= 59'h400000100050000;
        9'o452: ucode <= 59'h8000000;
        9'o460: ucode <= 59'h20400000000000;    // LEA
        9'o461: ucode <= 59'h8000000;
        9'o470: ucode <= 59'h20000000;    // SETLNS
        9'o471: ucode <= 59'h40000008000000;
        9'o500: ucode <= 59'h40000;    // SETLNS_IDX
        9'o501: ucode <= 59'h40000008000000;
        9'o510: ucode <= 59'h20000000;    // EXCHANGE
        9'o511: ucode <= 59'h1000000000000;
        9'o512: ucode <= 59'h8000000;
        9'o520: ucode <= 59'h20000000;    // TRANSFER
        9'o521: ucode <= 59'h200000000000000;
        9'o522: ucode <= 59'h8000000;
        9'o530: ucode <= 59'h8000000;    // NOPE
        9'o540: ucode <= 59'h20000000;    // SBRANCH
        9'o541: ucode <= 59'h800000000;
        9'o542: ucode <= 59'h8000000;
        9'o550: ucode <= 59'h20000000;    // SBSR
        9'o551: ucode <= 59'h18000000000;
        9'o553: ucode <= 59'h800000000;
        9'o554: ucode <= 59'h8000000;
        9'o560: ucode <= 59'h24000000;    // BSRL
        9'o561: ucode <= 59'h20000000;
        9'o562: ucode <= 59'h18000000000;
        9'o564: ucode <= 59'h400000000;
        9'o565: ucode <= 59'h8000000;
        9'o570: ucode <= 59'h24000000;    // LBRANCH
        9'o571: ucode <= 59'h20000000;
        9'o572: ucode <= 59'h400000000;
        9'o573: ucode <= 59'h8000000;
        9'o600: ucode <= 59'h1000000000;    // JUMP
        9'o601: ucode <= 59'h8000000;
        9'o610: ucode <= 59'h18000000000;    // JMSR
        9'o612: ucode <= 59'h1000000000;
        9'o613: ucode <= 59'h8000000;
        9'o620: ucode <= 59'h60000000000;    // RTIT
        9'o622: ucode <= 59'hA0000000000;
        9'o624: ucode <= 59'h8000000;
        9'o630: ucode <= 59'h30000000000;    // RTSR
        9'o633: ucode <= 59'h8000000;
        9'o640: ucode <= 59'h20000000;    // PSH
        9'o641: ucode <= 59'h8000000000;
        9'o644: ucode <= 59'h8000000;
        9'o650: ucode <= 59'h20000000;    // PUL
        9'o651: ucode <= 59'h20000000000;
        9'o654: ucode <= 59'h8000000;
        9'o660: ucode <= 59'h2000C00;    // RESET
        9'o664: ucode <= 59'h8000000;
        9'o670: ucode <= 59'hC000000000;    // FIRQ
        9'o671: ucode <= 59'hD00;
        9'o673: ucode <= 59'h2000000;
        9'o675: ucode <= 59'h8000000;
        9'o700: ucode <= 59'hA000000000;    // IRQ
        9'o701: ucode <= 59'hA00;
        9'o703: ucode <= 59'h2000000;
        9'o705: ucode <= 59'h8000000;
        9'o710: ucode <= 59'hA000000000;    // NMI
        9'o711: ucode <= 59'hE00;
        9'o713: ucode <= 59'h2000000;
        9'o715: ucode <= 59'h8000000;
        9'o720: ucode <= 59'h008;    // BUSERROR
        default: ucode <= 0;
    endcase
end
