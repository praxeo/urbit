/* gen164/5/ed_add_double_scalarmult.c
**
*/
#include "all.h"

#include <ed25519.h>
#include <ge.h>

#include "ge-additions.h"

/* functions
*/
  u3_noun
  u3qc_add_double_scalarmult(u3_atom a,
                             u3_atom a_point,
                             u3_atom b,
                             u3_atom b_point)
  {
    c3_y met_w;

    met_w = u3r_met(3, a);
    if (met_w > 32) {
      return u3m_bail(c3__fail);
    }
    c3_y a_y[32];
    memset(a_y, 0, 32);
    u3r_bytes(0, met_w, a_y, a);

    met_w = u3r_met(3, a_point);
    if (met_w > 32) {
      return u3m_bail(c3__fail);
    }
    c3_y a_point_y[32];
    memset(a_point_y, 0, 32);
    u3r_bytes(0, met_w, a_point_y, a_point);

    met_w = u3r_met(3, b);
    if (met_w > 32) {
      return u3m_bail(c3__fail);
    }
    c3_y b_y[32];
    memset(b_y, 0, 32);
    u3r_bytes(0, met_w, b_y, b);

    met_w = u3r_met(3, b_point);
    if (met_w > 32) {
      return u3m_bail(c3__fail);
    }
    c3_y b_point_y[32];
    memset(b_point_y, 0, 32);
    u3r_bytes(0, met_w, b_point_y, b_point);

    ge_p3 A;
    if (ge_frombytes_negate_vartime(&A, a_point_y) != 0) {
      return u3m_bail(c3__exit);
    }

    ge_p3 B;
    if (ge_frombytes_negate_vartime(&B, b_point_y) != 0) {
      return u3m_bail(c3__exit);
    }

    // Undo the negation from above. See add_scalar.c in the ed25519 distro.
    fe_neg(A.X, A.X);
    fe_neg(A.T, A.T);
    fe_neg(B.X, B.X);
    fe_neg(B.T, B.T);

    // Perform the multiplications of a*A and b*B
    ge_p3 a_result, b_result;
    ge_scalarmult(&a_result, a_y, &A);
    ge_scalarmult(&b_result, b_y, &B);

    // Sum those two points
    ge_cached b_result_cached;
    ge_p3_to_cached(&b_result_cached, &b_result);
    ge_p1p1 sum;
    ge_add(&sum, &a_result, &b_result_cached);

    ge_p3 final_result;
    ge_p1p1_to_p3(&final_result, &sum);

    c3_y output_y[32];
    ge_p3_tobytes(output_y, &final_result);

    return u3i_bytes(32, output_y);
  }

  u3_noun
  u3wee_add_double_scalarmult(u3_noun cor)
  {
    u3_noun a, b, c, d;

    if ( (c3n == u3r_mean(cor, u3x_sam_2, &a,
                               u3x_sam_6, &b,
                               u3x_sam_14, &c,
                               u3x_sam_15, &d, 0)) ||
         (c3n == u3ud(a)) ||
         (c3n == u3ud(b)) ||
         (c3n == u3ud(c)) )
    {
      return u3m_bail(c3__exit);
    } else {
      return u3qc_add_double_scalarmult(a, b, c, d);
    }
  }
