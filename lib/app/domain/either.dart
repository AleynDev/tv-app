class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool isLeft;

  Either._(this._left, this._right, this.isLeft);

  factory Either.left(L failure) {
    return Either._(failure, null, true);
  }

  factory Either.right(R value) {
    return Either._(null, value, false);
  }

  T when<T>(
    T Function(L) left,
    T Function(R) right,
  ) {
    if (isLeft) {
      return left(_left as L);
    } else {
      return right(_right as R);
    }
  }
}
