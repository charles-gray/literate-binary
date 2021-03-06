module Main where

import qualified Data.ByteString as BS
import Data.Semigroup ((<>))
import Data.String.Conversions (cs)
import qualified Data.Text.IO as TIO
import LiterateBinary (compile)
import Options.Applicative

main :: IO ()
main = getOpts >>= runCompiler

-- | Data type for command line options.
data Options = Options
    { optInput :: Maybe FilePath
    , optOutput :: Maybe FilePath
    }

-- | Parse command line options.
getOpts :: IO Options
getOpts = execParser $ info (helper <*> options) (fullDesc <> header hdr)
  where
    hdr = "lb - literate binary compiler"
    options = Options <$> input <*> output
    input =
        optional $
        argument str (metavar "FILE" <> help "Input file (default STDIN)")
    output =
        optional $
        strOption
            (long "output" <> short 'o' <> metavar "FILE" <>
             help "Output file (default STDOUT)")

-- | Run LiterateBinary.comile function based on command line options.
runCompiler :: Options -> IO ()
runCompiler (Options i o) = do
    text <- maybe TIO.getContents TIO.readFile i
    case compile text of
        Left err -> error $ cs err
        Right bin -> maybe (BS.putStr bin) (`BS.writeFile` bin) o
