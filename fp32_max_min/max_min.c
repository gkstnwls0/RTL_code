float SU_MAX(float a, float b) {
   if(a > b) return a;
   else      return b;
}

float SU_MIN(float a, float b) {
   if(a > b) return b;
   else      return a;
}

// Max 32bit (Onyl positive value)
float CAST_INT_TO_FP(int a) {
   // 0.0
   int i=0;
   int tmp_bit;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
   int msb_idx = 0;
   
   __uint32_t fp_s = 0;
   __uint32_t fp_e = 127;
   __uint32_t fp_m = 0;

   for(i=0;i<32;i++) {
      tmp_bit = (a >> i) & 0x1;
      if(tmp_bit == 1) msb_idx = i;
   }
   fp_e = fp_e + msb_idx;
   fp_m = (a << (23 - msb_idx)) & 0x7FFFFF;

   __uint32_t fp_int = fp_s << (31) | fp_e << 23 | fp_m;

   union fp32i u_fp32 = {fp_int};

   return u_fp32.fval;
}


int SU_CMP(float a, float b, int op) {
   // OP: 0 (>=), 1 (>), 2 (=), 3(<), 4 (<=)
   if(op == 0) {
      if(a >= b) return 1;
      else       return 0;
   } else if(op == 1) {
      if(a > b) return 1;
      else      return 0;      
   } else if(op == 2) {
      if(a == b) return 1;
      else       return 0;      
   } else if(op == 3) {
      if(a < b) return 1;
      else      return 0;      
   } else if(op == 4) {
      if(a <= b) return 1;
      else       return 0;      
   } else {
      printf("Error Not Support Ops!\n");
      return 0;
   }
}