-- Matrix math utility: multiply, transpose, and get the diagonal
import Data.List (transpose)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Text.Read (readMaybe)

-- | Rows of equal length, with at least one row and one column
type Matrix = [[Double]]

data Failure
    = InvalidInput
    | -- | Shapes of the left and right matrices
      ShapeMismatch (Int, Int) (Int, Int)

-- | Count of rows and columns
shape :: Matrix -> (Int, Int)
shape m = (length m, length (transpose m))

multiply :: Matrix -> Matrix -> Either Failure Matrix
multiply a b
    | snd (shape a) /= fst (shape b) = Left (ShapeMismatch (shape a) (shape b))
    | otherwise = Right [[sum (zipWith (*) row col) | col <- transpose b] | row <- a]

-- | Get the main diagonal, with a value per index in both dimensions
diagonal :: Matrix -> [Double]
diagonal ((x : _) : rows) = x : diagonal (map (drop 1) rows)
diagonal _ = []

-- | Read a row count, a column count, and the values in row-major order
readMatrix :: [String] -> Either Failure (Matrix, [String])
readMatrix (r : c : tokens)
    | Just rows <- readMaybe r
    , Just cols <- readMaybe c
    , rows > 0 && cols > 0
    , (values, rest) <- splitAt (rows * cols) tokens
    , length values == rows * cols
    , Just numbers <- traverse readMaybe values =
        Right (chunks cols numbers, rest)
  where
    chunks n = takeWhile (not . null) . map (take n) . iterate (drop n)
readMatrix _ = Left InvalidInput

run :: String -> Either Failure String
run input = do
    (a, rest) <- readMatrix (words input)
    (b, _) <- readMatrix rest
    ab <- multiply a b
    pure . unlines $
        section "A * B" ab ++ section "transpose(A)" (transpose a) ++ section "diagonal(A)" [diagonal a]
  where
    section title m = (title ++ ":") : map (unwords . map show) m

describe :: Failure -> String
describe InvalidInput = "error: cannot read matrix"
describe (ShapeMismatch (r1, c1) (r2, c2)) =
    "error: cannot multiply " ++ show r1 ++ "x" ++ show c1 ++ " matrix by " ++ show r2 ++ "x" ++ show c2 ++ " matrix"

main :: IO ()
main = getContents >>= either failWith putStr . run
  where
    failWith failure = hPutStrLn stderr (describe failure) >> exitFailure
