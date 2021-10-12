-- BIG THANKS TO VIDEO BY TSODING, https://www.youtube.com/watch?v=N9RUqGYuGfw&t=5128s&ab_channel=Tsoding, BIG HELP

module Parser
  ( bfParser,
    runParser,
    Parser,
    BFToken (..),
  )
where

import Control.Applicative

data BFToken
  = BfAdd
  | BfSub
  | BfLeft
  | BfRight
  | BfOut
  | BfIn
  | BfLoop [BFToken]
  deriving (Show, Eq)

newtype Parser a = Parser
  { runParser :: String -> Maybe (String, a)
  }

instance Functor Parser where
  fmap f (Parser p) =
    Parser $ \input -> do
      (input', x) <- p input
      Just (input', f x)

instance Applicative Parser where
  pure x = Parser $ \input -> Just (input, x)
  (Parser p1) <*> (Parser p2) =
    Parser $ \input -> do
      (input', f) <- p1 input
      (input'', a) <- p2 input'
      Just (input'', f a)

instance Alternative Parser where
  empty = Parser $ \_ -> Nothing
  (Parser p1) <|> (Parser p2) =
    Parser $ \input -> p1 input <|> p2 input

charP :: Char -> Parser Char
charP x = Parser f
  where
    f (y : ys)
      | y == x = Just (ys, x)
      | otherwise = Nothing
    f [] = Nothing

parseAdd :: Parser BFToken
parseAdd = BfAdd <$ charP '+'

parseSub :: Parser BFToken
parseSub = BfSub <$ charP '-'

parseIn :: Parser BFToken
parseIn = BfIn <$ charP ','

parseOut :: Parser BFToken
parseOut = BfOut <$ charP '.'

parseLeft :: Parser BFToken
parseLeft = BfLeft <$ charP '<'

parseRight :: Parser BFToken
parseRight = BfRight <$ charP '>'

parseLoop :: Parser BFToken
parseLoop = BfLoop <$> (charP '[' *> bfTokens <* charP ']')

bfTokens :: Parser [BFToken]
bfTokens = many (parseRight <|> parseLeft <|> parseAdd <|> parseSub <|> parseIn <|> parseOut <|> parseLoop)

bfParser :: Parser [BFToken]
bfParser = Parser $ \input -> runParser bfTokens (filter (\v -> v == '+' || v == '-' || v == '.' || v == ',' || v == '<' || v == '>' || v == '[' || v == ']') input)
