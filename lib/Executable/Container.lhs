The purpose of this module is to encapsulate different container formats
we may be able to handle, e.g. WinPE, ELF, A.OUT, etc. and allow us
to have a uniform interface to them so that our code remains general.
\begin{code}
module Executable.Container where
import Executable.Container.Type
import Executable.Container.ELF
\end{code}
