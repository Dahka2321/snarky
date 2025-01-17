(** Positive integers as field elements.

    These operations assert that the value of the field element does not exceed
    the largest element in the field -- ie. that the operations do not
    overflow.

    Whenever possible, the bit representation is cached to avoid recomputing
    it.
*)

open Snarky_backendless
open Snark
open Bitstring_lib

module Interval : sig
  open Util

  type t = Constant of B.t | Less_than of B.t
end

type ('f, 'v) t =
  { value : 'v; interval : Interval.t; mutable bits : 'v Boolean.t list option }

(** Create an value representing the given constant value.

    The bit representation of the constant is cached, and is padded to [length]
    when given.
*)
val constant : ?length:int -> m:('f, 'v) m -> Bigint.t -> ('f, 'v) t

(** [shift_left ~m x k] is equivalent to multiplying [x] by [2^k].

    The result has a cached bit representation whenever the given [x] had a
    cached bit representation.
*)
val shift_left : m:('f, 'v) m -> ('f, 'v) t -> int -> ('f, 'v) t

(** Create a value from the given bit string.

    The given bit representation is cached.
*)
val of_bits : m:('f, 'v) m -> 'v Boolean.t Bitstring.Lsb_first.t -> ('f, 'v) t

(** Compute the bit representation of the given integer.

    If the bit representation has already been cached, it is returned and no
    additional constraints are added. If the representation is computed, the
    value is updated to include the cache.
*)
val to_bits :
     ?length:int
  -> m:('f, 'v) m
  -> ('f, 'v) t
  -> 'v Boolean.t Bitstring.Lsb_first.t

(** Return the cached bit representation, or raise an exception if the bit
    representation has not been cached.
*)
val to_bits_exn : ('f, 'v) t -> 'v Boolean.t Bitstring.Lsb_first.t

(** Returns [Some bs] for [bs] the cached bit representation, or [None] if the
    bit representation has not been cached.
*)
val to_bits_opt : ('f, 'v) t -> 'v Boolean.t Bitstring.Lsb_first.t option

(** [div_mod ~m a b = (q, r)] such that [a = q * b + r] and [r < b].

    The bit representations of [q] and [r] are calculated and cached.

    NOTE: This uses approximately [log2(a) + 2 * log2(b)] constraints.
*)
val div_mod :
  m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> ('f, 'v) t * ('f, 'v) t

val to_field : ('f, 'v) t -> 'v

val create : value:'v -> upper_bound:Bigint.t -> ('f, 'v) t

(** [min ~m x y] returns a value equal the lesser of [x] and [y].

    The result does not carry a cached bit representation.
*)
val min : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> ('f, 'v) t

val if_ :
     m:('f, 'v) m
  -> 'v Boolean.t
  -> then_:('f, 'v) t
  -> else_:('f, 'v) t
  -> ('f, 'v) t

(** [succ ~m x] computes the successor [x+1] of [x].

    The result does not carry a cached bit representation.
*)
val succ : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t

(** [succ_if ~m x b] computes the integer [x+1] if [b] is [true], or [x]
    otherwise.

    The result does not carry a cached bit representation.
*)
val succ_if : m:('f, 'v) m -> ('f, 'v) t -> 'v Boolean.t -> ('f, 'v) t

val equal : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> 'v Boolean.t

val lt : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> 'v Boolean.t

val lte : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> 'v Boolean.t

val gt : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> 'v Boolean.t

val gte : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> 'v Boolean.t

(** [add ~m x y] computes [x + y].

    The result does not carry a cached bit representation.
*)
val add : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> ('f, 'v) t

(** [mul ~m x y] computes [x * y].

    The result does not carry a cached bit representation.
*)
val mul : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> ('f, 'v) t

(** [subtract_unpacking ~m x y] computes [x - y].

    The bit representation is calculated to ensure that [0 <= x - y], and is
    cached in the result.

    NOTE: This uses approximately [log2(x)] constraints.
*)
val subtract_unpacking : m:('f, 'v) m -> ('f, 'v) t -> ('f, 'v) t -> ('f, 'v) t

(** [subtract_unpacking_or_zero ~m x y] computes [x - y].

    - If the argument to [`Underflow] is true, [x < y] and the returned integer
      value is pinned to [zero].
    - If the argument to [`Underflow] is false, [x >= y] and the returned
      integer value is equal to [x - y].

    The bit representation is calculated to check for underflow.

    NOTE: This uses approximately [log2(x)] constraints.
*)
val subtract_unpacking_or_zero :
     m:('f, 'v) m
  -> ('f, 'v) t
  -> ('f, 'v) t
  -> [ `Underflow of 'v Boolean.t ] * ('f, 'v) t
