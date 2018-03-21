/**
 * The actions that can be performed by File_Management.
 * <ul>
 * <li>NoOp is a no operation place holder.</li>
 * <li>Replace is used to replace the Current logical
 * file with the new logical file.</li>
 * <li>Add is used to add the new logical file into
 * the current list</li>
 * </ul>
 * In both Add and Replace, the definitions are
 * rotated through the list of Current, Previous,
 * past Previous, and Deleted.
 */
EXPORT Task := ENUM(UNSIGNED1, NoOp=0, Replace, Add);
