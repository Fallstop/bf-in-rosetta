{-# LANGUAGE LambdaCase #-}

module Main where

import Control.Monad
import Data.Char
import Data.Maybe
import Interpreter
import Parser
import System.IO
import Text.Printf

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
    forM
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

  let inputsParsed =
        map
          ( \case
              "" -> 0
              x -> read x :: Int
          )
          inputs

  putStrLn "Inputs: "
  forM_ inputsParsed (printf "%d\n")
  let z = runBf tokens inputsParsed
  putStrLn "Outputs: "
  forM_ (outputs z) (printf "%d\n")
