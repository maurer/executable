The basic information we expect to get out of a container is
* How the memory image of the program will look when loaded (possibly with shared libraries, but that's def. future work)
* The entry point
* The architecture
* The expected environment (e.g. OS)

\begin{code}
module Executable.Container.Type
(ExecContainer(..)
,module Executable.Data.MemMap
,Arch(..)
,OS(..)
) where
import Executable.Arch
import Executable.OS
import Executable.Data.MemMap

data ExecContainer = EC {
   ecMemMap :: MemMap
  ,ecArch   :: Arch
  ,ecEntry  :: Word64
  ,ecOS     :: OS
}

\end{code}
