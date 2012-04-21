This module is intended to contain a fast map of a process image.

Regular maps and arrays both fall short here, because it is too sparse for an array, but has dense patches making a map inefficient. Instead I am constructing something that could be described as a region map, which is basically a map of arrays.


\begin{code}
module Executable.Data.MemMap (MemMap) where
import Data.IntervalMap.FingerTree
import qualified Data.ByteString as BS
import Executable.MachTypes

data RWX = R | RX | RW

data MemRegion = MR {mrPayload :: BS.ByteString
                    ,mrPerms :: RWX
                    }

data MemMap = MM (IntervalMap Addr MemRegion)
\end{code}
