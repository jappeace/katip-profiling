{-# LANGUAGE TemplateHaskell #-}
module Template
  ( main
  )
where

import Katip
import Control.Exception
import System.IO(stdout)
import Data.Text(Text)

main :: IO ()
main = do
  handleScribe <- mkHandleScribe ColorIfTerminal stdout (permitItem InfoS) V2
  let makeLogEnv = registerScribe "stdout" handleScribe defaultScribeSettings =<< initLogEnv "MyApp" "production"
  -- closeScribes will stop accepting new logs, flush existing ones and clean up resources
  bracket makeLogEnv closeScribes $ \le -> do
      runKatipContextT le () "logloop" $ do
          logLoop

someContext :: Text
someContext = "yy"

logLoop :: KatipContextT IO ()
logLoop = do
  katipSetContext "xx" someContext $ do
      $(logTM) InfoS "Hello Katip"
      logLoop
