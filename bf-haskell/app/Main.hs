{-# LANGUAGE LambdaCase #-}

module Main where

import Control.Monad
import Data.Maybe
import Parser
import System.IO

getInput :: String -> IO String
getInput text = do
  putStr text
  hFlush stdout
  getLine

main = do
  putStr "? Code Path> "
  hFlush stdout
  path <- getLine
  handle <- openFile path ReadMode
  contents <- hGetContents handle
  let (_, tokens) = fromJust (runParser bfParser contents)

  let yes = map (\f -> getInput (show f ++ " ?> ")) [1, 2, 3, 4, 5]

  -- Will only get as many inputs as there are commas in the source code
  inputs <-
    forM_
      [ 1
        .. length
          ( filter
              ( \case
                  Parser.BfIn -> True
                  otherwise -> False
              )
              tokens
          )
      ]
      (\i -> getInput (show i ++ " ?> "))

  putStrLn ""
