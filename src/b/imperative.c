#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Word {
  char *text;
  size_t count;
};

/* Count text unless it is a stop word; return zero if a limit is reached. */
static int count_word(struct Word **words, size_t *length, size_t *capacity,
                      const char *text) {
  static const char *const stop_words[] = {
      "a",    "an",   "and",  "are", "as",  "at",   "be",  "by",
      "for",  "from", "in",   "is",  "it",  "of",   "on",  "or",
      "that", "the",  "this", "to",  "was", "were", "with"};

  size_t num_words = sizeof stop_words / sizeof stop_words[0];
  for (size_t i = 0; i < num_words; ++i) {
    if (strcmp(text, stop_words[i]) == 0) {
      return 1;
    }
  }

  for (size_t i = 0; i < *length; ++i) {
    if (strcmp(text, (*words)[i].text) == 0) {
      if ((*words)[i].count == SIZE_MAX) {
        return 0;
      }
      ++(*words)[i].count;
      return 1;
    }
  }

  if (*length == *capacity) {
    if (*capacity > SIZE_MAX / sizeof **words / 2) {
      return 0;
    }
    size_t new_capacity = *capacity == 0 ? 16 : *capacity * 2;
    struct Word *grown = realloc(*words, new_capacity * sizeof **words);
    if (grown == NULL) {
      return 0;
    }
    *words = grown;
    *capacity = new_capacity;
  }

  char *copy = malloc(strlen(text) + 1);
  if (copy == NULL) {
    return 0;
  }
  strcpy(copy, text);
  (*words)[*length].text = copy;
  (*words)[*length].count = 1;
  ++*length;
  return 1;
}

/* Order word records by descending count, then ascending text. */
static int compare_words(const void *left, const void *right) {
  const struct Word *a = left;
  const struct Word *b = right;

  if (a->count != b->count) {
    return a->count < b->count ? 1 : -1;
  }
  return strcmp(a->text, b->text);
}

int main(void) {
  struct Word *words = NULL;
  size_t word_count = 0;
  size_t word_capacity = 0;
  size_t token_length = 0;
  size_t token_capacity = 64;
  char *token = malloc(token_capacity);
  int status = EXIT_FAILURE;

  if (token == NULL) {
    goto cleanup;
  }

  for (;;) {
    int c = getchar();

    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
      if (token_length + 1 == token_capacity) {
        if (token_capacity > SIZE_MAX / 2) {
          goto cleanup;
        }
        size_t new_capacity = token_capacity * 2;
        char *grown = realloc(token, new_capacity);
        if (grown == NULL) {
          goto cleanup;
        }
        token = grown;
        token_capacity = new_capacity;
      }
      if (c >= 'A' && c <= 'Z') {
        c += 'a' - 'A';
      }
      token[token_length++] = (char)c;
    } else if (token_length != 0) {
      token[token_length] = '\0';
      if (!count_word(&words, &word_count, &word_capacity, token)) {
        goto cleanup;
      }
      token_length = 0;
    }

    if (c == EOF) {
      break;
    }
  }

  if (ferror(stdin)) {
    goto cleanup;
  }
  if (word_count > 1) {
    qsort(words, word_count, sizeof *words, compare_words);
  }
  for (size_t i = 0; i < word_count && i < 5; ++i) {
    if (printf("%s %zu\n", words[i].text, words[i].count) < 0) {
      goto cleanup;
    }
  }
  if (fflush(stdout) == EOF) {
    goto cleanup;
  }
  status = EXIT_SUCCESS;

cleanup:
  for (size_t i = 0; i < word_count; ++i) {
    free(words[i].text);
  }
  free(words);
  free(token);
  if (status != EXIT_SUCCESS) {
    fputs("Failed to process text.\n", stderr);
  }
  return status;
}
