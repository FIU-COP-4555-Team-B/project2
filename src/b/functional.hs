import Data.Char (isAsciiLower, isAsciiUpper, toLower)
import Data.List (sortOn)
import qualified Data.Map.Strict as Map
import Data.Ord (Down (..))
import qualified Data.Set as Set

stopWords :: Set.Set String
stopWords =
    Set.fromList
        (words "a an and are as at be by for from in is it of on or that the this to was were with")

tokenize :: String -> [String]
tokenize = words . map normalize
  where
    normalize c
        | isAsciiLower c || isAsciiUpper c = toLower c
        | otherwise = ' '

topWords :: String -> [(String, Int)]
topWords =
    take 5
        . sortOn (\(word, count) -> (Down count, word))
        . Map.toList
        . Map.fromListWith (+)
        . map (\word -> (word, 1))
        . filter (`Set.notMember` stopWords)
        . tokenize

main :: IO ()
main = getContents >>= putStr . unlines . map format . topWords
  where
    format (word, count) = word ++ " " ++ show count
