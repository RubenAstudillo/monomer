module Monomer.Widget.Widgets.Grid (
  hgrid,
  vgrid
) where

import Control.Monad
import Data.Default
import Data.List (foldl')
import Data.Sequence (Seq(..), (|>))

import qualified Data.Sequence as Seq

import Monomer.Common.Geometry
import Monomer.Common.Tree
import Monomer.Widget.Types
import Monomer.Widget.Util
import Monomer.Widget.BaseContainer

hgrid :: (Traversable t) => t (WidgetInstance s e) -> WidgetInstance s e
hgrid children = (defaultWidgetInstance "hgrid" (makeFixedGrid True)) {
  _instanceChildren = foldl' (|>) Empty children
}

vgrid :: (Traversable t) => t (WidgetInstance s e) -> WidgetInstance s e
vgrid children = (defaultWidgetInstance "vgrid" (makeFixedGrid False)) {
  _instanceChildren = foldl' (|>) Empty children
}

makeFixedGrid :: Bool -> Widget s e
makeFixedGrid isHorizontal = widget where
  widget = createContainer {
    _widgetPreferredSize = containerPreferredSize preferredSize,
    _widgetResize = containerResize resize
  }

  preferredSize wenv widgetInst children reqs = Node reqSize reqs where
    (vchildren, vreqs) = visibleChildrenReq children reqs
    reqSize = SizeReq (Size width height) FlexibleSize FlexibleSize
    width
      | Seq.null vchildren = 0
      | otherwise = wMul * (maximum . fmap (_w . _sizeRequested)) vreqs
    height
      | Seq.null vchildren = 0
      | otherwise = hMul * (maximum . fmap (_h . _sizeRequested)) vreqs
    wMul
      | isHorizontal = fromIntegral (length vchildren)
      | otherwise = 1
    hMul
      | isHorizontal = 1
      | otherwise = fromIntegral (length vchildren)

  resize wenv viewport renderArea widgetInst children reqs = resized where
    Rect l t w h = renderArea
    vchildren = Seq.filter _instanceVisible children
    cols = if isHorizontal then length vchildren else 1
    rows = if isHorizontal then 1 else length vchildren
    cw = if cols > 0 then w / fromIntegral cols else 0
    ch = if rows > 0 then h / fromIntegral rows else 0
    cx i
      | rows > 0 = l + fromIntegral (i `div` rows) * cw
      | otherwise = 0
    cy i
      | cols > 0 = t + fromIntegral (i `div` cols) * ch
      | otherwise = 0
    foldHelper (newAreas, index) child = (newAreas |> newArea, newIndex) where
      visible = _instanceVisible child
      newIndex = index + if _instanceVisible child then 1 else 0
      newViewport = if visible then calcViewport index else def
      newArea = (newViewport, newViewport)
    calcViewport i = Rect (cx i) (cy i) cw ch
    assignedAreas = fst $ foldl' foldHelper (Seq.empty, 0) vchildren
    resized = (widgetInst, assignedAreas)
