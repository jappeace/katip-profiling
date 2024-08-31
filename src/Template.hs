module Template
  ( main
  )
where

import Katip

main :: IO ()
main = do
  handleScribe <- mkHandleScribe ColorIfTerminal stdout (permitItem InfoS) V2
  let makeLogEnv = registerScribe "stdout" handleScribe defaultScribeSettings =<< initLogEnv "MyApp" "production"
  -- closeScribes will stop accepting new logs, flush existing ones and clean up resources
  bracket makeLogEnv closeScribes $ \le -> do
      runKatipContextT le initialContext "logloop" $ do
          logLoop

logLoop :: KatipT IO ()
logLoop = do
  katipAddContext (sl "xx" "yy") $
      $(logTM) InfoS "Hello Katip"
      logLoop
