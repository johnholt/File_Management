File Management Bundle.

This module can be used to control the file promotion process when
one or more files (or keys) must be promoted together.  All of the
promotion activity occurs within a transaction.

There are 3 levels, Current, Previous, and Past Previous.  A fourth
level, Deleted, is used as a temporary to hold the newly deleted
files so that they can be physically deleted (if requested) outside
of the transaction context.

There are two actions available, Replace and Add.  In both cases, the
Deleted definition is cleared before the start.  In both cases, the
SuperFile entries are created if they have not already been created.

The Replace Action swaps the Past Previous definition with the Deleted
definition; swaps the Previous defintion with the Past Previous
definition; and swaps the Current definition with the Previous definition
in the transaction.  The new logical file name is then added to the
Current definition.

The Add Action first copies the Current definition into the Deleted
definition prior to the transaction start.  The Replace action process
is then followed.  This results in the new Current definition having the
same list of file names as the new Previous definition plus the new
logical file name.

The list of file is optionally deleted outside of the transaction.  The
files are deleted if: 1) the delete flag was TRUE; and 2) the file name
is not in another super file definition.  In all cases, the Deleted
definition is cleared.
