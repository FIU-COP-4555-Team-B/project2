/* Matrix math utility: multiply, transpose, and get the diagonal */
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/* Matrix with at least one row and one column */
typedef struct {
  size_t rows;
  size_t cols;
  double values[]; /* Row-major order */
} Matrix;

/* Make a matrix with unset values; return NULL if memory is not available */
static Matrix *matrix_new(size_t rows, size_t cols) {
  assert(rows > 0 && cols > 0);
  if (cols > (SIZE_MAX - sizeof(Matrix)) / sizeof(double) / rows) {
    return NULL;
  }
  Matrix *m = malloc(sizeof(Matrix) + rows * cols * sizeof(double));
  if (m != NULL) {
    m->rows = rows;
    m->cols = cols;
  }
  return m;
}

/* Get the index of row and col in m->values */
static size_t at(const Matrix *m, size_t row, size_t col) {
  return row * m->cols + col;
}

/* The cols of a must equal the rows of b */
static Matrix *matrix_multiply(const Matrix *a, const Matrix *b) {
  assert(a->cols == b->rows);
  Matrix *product = matrix_new(a->rows, b->cols);
  if (product == NULL) {
    return NULL;
  }
  for (size_t i = 0; i < a->rows; ++i) {
    for (size_t j = 0; j < b->cols; ++j) {
      double sum = 0.0;
      for (size_t k = 0; k < a->cols; ++k) {
        sum += a->values[at(a, i, k)] * b->values[at(b, k, j)];
      }
      product->values[at(product, i, j)] = sum;
    }
  }
  return product;
}

static Matrix *matrix_transpose(const Matrix *m) {
  Matrix *transpose = matrix_new(m->cols, m->rows);
  if (transpose == NULL) {
    return NULL;
  }
  for (size_t i = 0; i < m->rows; ++i) {
    for (size_t j = 0; j < m->cols; ++j) {
      transpose->values[at(transpose, j, i)] = m->values[at(m, i, j)];
    }
  }
  return transpose;
}

/* Make one row of the main diagonal, with a value per index in both
 * dimensions */
static Matrix *matrix_diagonal(const Matrix *m) {
  Matrix *diagonal = matrix_new(1, m->rows < m->cols ? m->rows : m->cols);
  if (diagonal == NULL) {
    return NULL;
  }
  for (size_t i = 0; i < diagonal->cols; ++i) {
    diagonal->values[i] = m->values[at(m, i, i)];
  }
  return diagonal;
}

/* Read a row count, a column count, and the values in row-major order;
 * return NULL if the input is not valid or memory is not available */
static Matrix *read_matrix(void) {
  int rows;
  int cols;
  if (scanf("%d %d", &rows, &cols) != 2 || rows < 1 || cols < 1) {
    return NULL;
  }
  Matrix *m = matrix_new((size_t)rows, (size_t)cols);
  if (m == NULL) {
    return NULL;
  }
  for (size_t i = 0; i < m->rows * m->cols; ++i) {
    if (scanf("%lf", &m->values[i]) != 1) {
      free(m);
      return NULL;
    }
  }
  return m;
}

/* Write the title, then each row on a line */
static void print_matrix(const char *title, const Matrix *m) {
  printf("%s:\n", title);
  for (size_t i = 0; i < m->rows; ++i) {
    for (size_t j = 0; j < m->cols; ++j) {
      printf(j == 0 ? "%g" : " %g", m->values[at(m, i, j)]);
    }
    putchar('\n');
  }
}

int main(void) {
  Matrix *a = read_matrix();
  Matrix *b = read_matrix();
  Matrix *product = NULL;
  Matrix *transpose = NULL;
  Matrix *diagonal = NULL;
  int status = EXIT_FAILURE;

  if (a == NULL || b == NULL) {
    fputs("error: cannot read matrix\n", stderr);
    goto cleanup;
  }
  if (a->cols != b->rows) {
    fprintf(stderr, "error: cannot multiply %zux%zu matrix by %zux%zu matrix\n",
            a->rows, a->cols, b->rows, b->cols);
    goto cleanup;
  }
  product = matrix_multiply(a, b);
  transpose = matrix_transpose(a);
  diagonal = matrix_diagonal(a);
  if (product == NULL || transpose == NULL || diagonal == NULL) {
    fputs("error: out of memory\n", stderr);
    goto cleanup;
  }

  print_matrix("A * B", product);
  print_matrix("transpose(A)", transpose);
  print_matrix("diagonal(A)", diagonal);
  status = EXIT_SUCCESS;

cleanup:
  free(a);
  free(b);
  free(product);
  free(transpose);
  free(diagonal);
  return status;
}
