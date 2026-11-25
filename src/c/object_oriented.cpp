// Matrix math utility: multiply, transpose, and get the diagonal

#include <algorithm>
#include <cstddef>
#include <cstdlib>
#include <format>
#include <iostream>
#include <stdexcept>
#include <vector>

// Matrix with at least one row and one column
class Matrix {
public:
  // Make a matrix of zeros; throw std::invalid_argument if a dimension is zero
  Matrix(std::size_t rows, std::size_t cols)
      : rows_(rows), cols_(cols), values_(rows * cols) {
    if (rows == 0 || cols == 0) {
      throw std::invalid_argument("matrix has no values");
    }
  }

  std::size_t rows() const noexcept { return rows_; }
  std::size_t cols() const noexcept { return cols_; }

  // Get the value at row and col, which must be in the matrix
  double &operator()(std::size_t row, std::size_t col) {
    return values_[row * cols_ + col];
  }
  double operator()(std::size_t row, std::size_t col) const {
    return values_[row * cols_ + col];
  }

  Matrix transpose() const {
    Matrix result(cols_, rows_);
    for (std::size_t i = 0; i < rows_; ++i) {
      for (std::size_t j = 0; j < cols_; ++j) {
        result(j, i) = (*this)(i, j);
      }
    }
    return result;
  }

  // Get one row of the main diagonal, with a value per index in both
  // dimensions
  Matrix diagonal() const {
    Matrix result(1, std::min(rows_, cols_));
    for (std::size_t i = 0; i < result.cols(); ++i) {
      result(0, i) = (*this)(i, i);
    }
    return result;
  }

private:
  std::size_t rows_;
  std::size_t cols_;
  std::vector<double> values_; // Row-major order
};

// Throw std::invalid_argument if the cols of a do not equal the rows of b
Matrix operator*(const Matrix &a, const Matrix &b) {
  if (a.cols() != b.rows()) {
    throw std::invalid_argument(
        std::format("cannot multiply {}x{} matrix by {}x{} matrix", a.rows(),
                    a.cols(), b.rows(), b.cols()));
  }
  Matrix product(a.rows(), b.cols());
  for (std::size_t i = 0; i < a.rows(); ++i) {
    for (std::size_t j = 0; j < b.cols(); ++j) {
      for (std::size_t k = 0; k < a.cols(); ++k) {
        product(i, j) += a(i, k) * b(k, j);
      }
    }
  }
  return product;
}

// Read a row count, a column count, and the values in row-major order
Matrix read_matrix(std::istream &in) {
  int rows = 0;
  int cols = 0;
  if (in >> rows >> cols && rows > 0 && cols > 0) {
    Matrix m(rows, cols);
    for (std::size_t i = 0; i < m.rows(); ++i) {
      for (std::size_t j = 0; j < m.cols(); ++j) {
        in >> m(i, j);
      }
    }
    if (in) {
      return m;
    }
  }
  throw std::runtime_error("cannot read matrix");
}

// Write each row on a line, with spaces between values
std::ostream &operator<<(std::ostream &out, const Matrix &m) {
  for (std::size_t i = 0; i < m.rows(); ++i) {
    for (std::size_t j = 0; j < m.cols(); ++j) {
      out << (j == 0 ? "" : " ") << m(i, j);
    }
    out << '\n';
  }
  return out;
}

int main() {
  try {
    const Matrix a = read_matrix(std::cin);
    const Matrix b = read_matrix(std::cin);
    const Matrix product = a * b;
    std::cout << "A * B:\n"
              << product << "transpose(A):\n"
              << a.transpose() << "diagonal(A):\n"
              << a.diagonal();
  } catch (const std::exception &e) {
    std::cerr << "error: " << e.what() << '\n';
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
