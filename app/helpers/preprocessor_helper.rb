module PreprocessorHelper
  def compare_strings(str1, str2)
    return 0 if str1.nil? || str2.nil?

    str1 = str1.downcase
    str2 = str2.downcase

    str1_normalized = str1.downcase.gsub(/[^a-z]/, '')
    str2_normalized = str2.downcase.gsub(/[^a-z]/, '')

    jaro_winkler_similarity = JaroWinkler.distance(str1_normalized, str2_normalized)
    levenshtein_similarity = 1 - (Text::Levenshtein.distance(str1_normalized, str2_normalized).to_f / [str1_normalized.length, str2_normalized.length].max)

    { jaro_winkler: jaro_winkler_similarity, levenshtein: levenshtein_similarity }
  end

end
