module Interpreter
  ( runBf,
    BFEnv (..),
  )
where

import Parser

data BFEnv = BFEnv
  { memory :: [Int],
    outputs :: [Int],
    ptr :: Int,
    inputs :: [Int]
  }

newEnv :: [Int] -> BFEnv
newEnv = BFEnv (replicate 30000 0) [] 0

runBf :: [BFToken] -> [Int] -> BFEnv
runBf tokens inputs = interpretTokens (newEnv inputs) tokens

interpretTokens :: BFEnv -> [BFToken] -> BFEnv
interpretTokens = foldl exec1

exec1 :: BFEnv -> BFToken -> BFEnv
exec1 env BfAdd =
  BFEnv
    (incAt (ptr env) (memory env))
    (outputs env)
    (ptr env)
    (inputs env)
exec1 env BfSub =
  BFEnv
    (decAt (ptr env) (memory env))
    (outputs env)
    (ptr env)
    (inputs env)
exec1 env BfLeft =
  BFEnv
    (memory env)
    (outputs env)
    (decPtr (ptr env))
    (inputs env)
exec1 env BfRight =
  BFEnv
    (memory env)
    (outputs env)
    (incPtr (ptr env))
    (inputs env)
exec1 env BfOut =
  BFEnv
    (memory env)
    (outputs env ++ [memory env !! ptr env])
    (ptr env)
    (inputs env)
exec1 env BfIn =
  BFEnv
    newMem
    (outputs env)
    (ptr env)
    is
  where
    (i : is) = case inputs env of
      [] -> [0, 0]
      [a] -> [a, 0]
      a -> a
    (a, _ : bs) = splitAt (ptr env) (memory env)
    newMem = a ++ [i] ++ bs
exec1 env (BfLoop tokens) = newEnv
  where
    processed = interpretTokens env tokens
    newEnv =
      if (memory processed !! ptr processed) /= 0
        then exec1 processed (BfLoop tokens)
        else processed

incPtr :: (Eq p, Num p) => p -> p
incPtr 29999 = 0
incPtr x = x + 1

decPtr :: (Eq p, Num p) => p -> p
decPtr 0 = 29999
decPtr x = x - 1

incAt :: (Eq a, Num a) => Int -> [a] -> [a]
incAt pos input = a ++ [c] ++ bs
  where
    (a, b : bs) = splitAt pos input
    c = if b == 255 then 0 else b + 1

decAt :: (Eq a, Num a) => Int -> [a] -> [a]
decAt pos input = a ++ [c] ++ bs
  where
    (a, b : bs) = splitAt pos input
    c = if b == 0 then 255 else b - 1