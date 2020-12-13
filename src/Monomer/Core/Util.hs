module Monomer.Core.Util where

import Control.Lens ((&), (^.), (.~), (?~))
import Data.Sequence (Seq(..))
import Data.Text (Text)

import Monomer.Core.BasicTypes
import Monomer.Core.Style
import Monomer.Core.WidgetTypes

import qualified Monomer.Lens as L

isMacOS :: WidgetEnv s e -> Bool
isMacOS wenv = _weOS wenv == "Mac OS X"

widgetTreeDesc :: Int -> WidgetNode s e -> String
widgetTreeDesc level node = desc where
  desc = nodeDesc level node ++ "\n" ++ childDesc
  childDesc = foldMap (widgetTreeDesc (level + 1)) (_wnChildren node)

nodeDesc :: Int -> WidgetNode s e -> String
nodeDesc level node = infoDesc (_wnInfo node) where
  spaces = replicate (level * 2) ' '
  infoDesc info =
    spaces ++ "type: " ++ unWidgetType (_wniWidgetType info) ++ "\n" ++
    spaces ++ "path: " ++ show (_wniPath info) ++ "\n" ++
    spaces ++ "vp: " ++ rectDesc (_wniViewport info) ++ "\n" ++
    spaces ++ "req: " ++ show (_wniSizeReqW info, _wniSizeReqH info) ++ "\n"
  rectDesc r = show (_rX r, _rY r, _rW r, _rH r)

maxNumericValue :: (RealFloat a) => a
maxNumericValue = x where
  n = floatDigits x
  b = floatRadix x
  (_, u) = floatRange x
  x = encodeFloat (b^n - 1) (u - n)

numberInBounds :: (Ord a, Num a) => Maybe a -> Maybe a -> a -> Bool
numberInBounds Nothing Nothing _ = True
numberInBounds (Just minVal) Nothing val = val >= minVal
numberInBounds Nothing (Just maxVal) val = val <= maxVal
numberInBounds (Just minVal) (Just maxVal) val = val >= minVal && val <= maxVal
