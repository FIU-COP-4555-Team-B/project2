import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class ObjectOriented {
  private static final Pattern WORD = Pattern.compile("[A-Za-z]+");
  private static final Set<String> STOP_WORDS = Set.of(
      "a", "an", "and", "are", "as", "at", "be", "by", "for", "from",
      "in", "is", "it", "of", "on", "or", "that", "the", "this", "to",
      "was", "were", "with");

  private final Map<String, Long> frequencies = new HashMap<>();

  public static void main(String[] args) throws IOException {
    ObjectOriented analyzer = new ObjectOriented();

    try (BufferedReader input = new BufferedReader(
        new InputStreamReader(System.in, StandardCharsets.UTF_8))) {
      analyzer.analyze(input);
    }

    analyzer.printTopWords();
  }

  private void analyze(BufferedReader input) throws IOException {
    String line;
    while ((line = input.readLine()) != null) {
      Matcher words = WORD.matcher(line);
      while (words.find()) {
        String word = words.group().toLowerCase(Locale.ROOT);
        if (!STOP_WORDS.contains(word)) {
          frequencies.put(word, frequencies.getOrDefault(word, 0L) + 1);
        }
      }
    }
  }

  private void printTopWords() {
    List<Map.Entry<String, Long>> words = new ArrayList<>(frequencies.entrySet());
    words.sort((left, right) -> {
      int byCount = Long.compare(right.getValue(), left.getValue());
      return byCount != 0 ? byCount : left.getKey().compareTo(right.getKey());
    });

    for (int i = 0; i < Math.min(5, words.size()); i++) {
      Map.Entry<String, Long> word = words.get(i);
      System.out.println(word.getKey() + " " + word.getValue());
    }
  }
}
