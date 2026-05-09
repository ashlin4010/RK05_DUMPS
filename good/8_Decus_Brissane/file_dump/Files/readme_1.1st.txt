                GETTING ON THE AIR WITH RSX-11/IAS RUNOFF
			(As adapted for RT11)

RT11 SYSTEMS

Transfer the .MAC files and RUNOFF.COM (optionally RUNOFX.COM) to DK:.  Assign
a device LST for the listings, and MAP for the load map (NL: if not wanted).
Then type "@RUNOFF" (and later if desired "@RUNOFX") to produce RUNOFF.SAV
(and RUNOFX.SAV).

RUNOFF.SAV is the standard RUNOFF as per the manual.  RUNOFX is an
experimental version which instead of storing index data in memory sends it
out to the second file specified in the output file list.  Thereafter it can
be sorted and re-introduced to RUNOFX as a source file, providing a facility
for dealing with .RNO files with indices larger than can be accomodated
otherwise.

Example:
			Source File:

		.title	Example for RUNOFX
		.....
		.number appendix I
		.AX INDEX
		.nf
		.;This is the end of the file.  It is here
		.;that the sorted index file will be appended.

			Operation:

		.RUN RUNOFX
		*NL:,DK:INDEX.DAT=SOURCE
		(No need for normal output, hence NL:.  Note that
		it is still necessary to specify an output file, and
		that the DK: must be specified to follow it!)
		*^C
		.!At this point, sort INDEX.DAT, and rearrange if
		.!desired (as puts page numbers before text).
		.RUN RUNOFX
		*SOURCE=SOURCE,INDEX.DAT
		(No need to specify an index file if not wanted.)

RSX-11M MAPPED SYSTEMS

All command files follow the standard RSX-11M conventions.

	1.  [100,10] should contain all source modules.

	2.  [100,20] should contain the file RNOASM.CMD.

	3.  [100,20] will recieve the object output files.

	4.  [100,30] will receive listing files.

	5.  [1,20] should contain the file RNOBLD.ODL

	6.  [1,24] should contain the file RNOBLD.CMD

	7.  [1,34] will receive the map output file.

	8.  [1,54] will receive the task image file.

Procedure:

	1.  Use UFD to set up the proper UFDs, if necessary.   Note
		that all command files must be changed if you do not do
		this.

	2.  Use FLX to move the files to their proper UICs.

	3.  Set the UIC to [100,20] and assemble.
		SET /UIC=[100,20]
		MAC @RNOASM

	4.  Use PIP to construct a concatenated object file for all
		RNO files:
			PIP>RNO.OBS=*.OBJ

	5.  SET THE UIC to [1,20] and build  a  library  containing
		the RNO object files:
			SET /UIC=[1,20]
			LBR>RNO/CR=[100,20]RNO.OBS

	6.  Edit the  Task  Build  command  file  to  reflect  your
		individual  system  needs.  The Task Build command file
		contains  parameters  to  set  the  default   switches,
		default  paper  size  (for  /-FF) and default underline
		mode.

	7.  Build the task image file.  The map will go  to  [1,34]
		and the task image to [1,54].
			TKB @[1,24]RNOBLM



RSX-11M UNMAPPED SYSTEMS

Users of unmapped systems should follow the  procedure  outlined
for  mapped  systems,  but  selecting UICs as appropriate.  File
RNOBLD.CMD will have to be edited to delete the /MM  switch  and
to change the PAR directive to match system requirements.


RSX-11D/IAS

Users of RSX-11D/IAS should follow the  procedure  outlined  for
users  of  RSX-11M  Mapped  systems.   Since the conventions for
source and object files are installation dependent, all .CMD and
.ODL   files   should   be  edited  accordingly.   Additionally,
RSX-11D/IAS users should alter  RNOBLD.CMD  to  change  the  /MM
switch to /MU and to change the PAR directive as needed.

Alternatively, IAS users may  use  command  file  RNOIAS.CMD  to
assemble and build RUNOFF.  The command file contains parameters
to set the default switches, default paper size (for  /-FF)  and
default underline mode.


RSTS/E

To build RUNOFF under RSTS/E V06C-03  systems,  run  the  $BUILD
program   and   specify  the  RNOBLD.CTL  control  file  on  the
distribution medium.  RNOBLD.CTL assumes  that  all  files  have
been copied to account [100,100] (use PIP.SAV).  If users desire
to build directly from the distribution of from another account,
it  will be necessary to edit RNOBLD.CTL to change references to
[100,100] to the [p,pn] used in the distribution.  Both the RT11
and  RSX  Run-Time Systems are assumed present in the system, as
the PIP.SAV, MAC.TSK, LBR.TSK, and TKB.TSK programs are required
in  the  build  procedure.   The  Task Builder run will normally
produce the message:

?TKB -- *DIAG*-MODULE ERR    MULTIPLY DEFINES SYMBOL EOF

This is not an error.  At the  (successful)  completion  of  the
procedure, RNO will be ready to run.

The last step of RNOBLD.CTL copies the files  necessary  to  use
RNO  (i.e., RNO.TSK and RUNOFF.RNO) to account [1,2].  This step
should be deleted or changed if users do not desire to store RNO
in [1,2].

To use the  Concise-command  language  feature  of  RSTS/E,  the
following CCL command should be installed:

		CCL RNO=[P,PN]RNO.TSK

RNO.TSK is not a privileged program.   It  should,  however,  be
installed  with  an <104> protection code if it is desirable for
all users on the system to access it.

	CONTENTS OF THE DISTRIBUTION

RNOASM.CMD   - Assembly command file for RSX-11M
RNOBLD.CMD   - Task builder command file for RSX-11M
RNOBLD.CTL   - RSTS/E build control file
RNOBLD.ODL   - Overlay description for RSX-11M
RNO.ODL      - Overlay descriptor for RSTS/E
RNOIAS.CMD   - Command file for IAS
RNOIAS.ODL   - Overlay descriptor for IAS
RSTASM.CMD   - Assembly command file for RSTS/E
RSTBLD.CMD   - Task builder command file for RSTS/E
CMTAB.MAC    - RUNOFF source file
COMND.MAC    - RUNOFF source file
ERMSG.MAC    - RUNOFF source file
FMTCM.MAC    - RUNOFF source file
HYPHEN.MAC   - RUNOFF source file
INDEX.MAC    - RUNOFF source file
PINDX.MAC    - RUNOFF source file
RNCMD.MAC    - RUNOFF source file
RNFIO.MAC    - RUNOFF source file
RNORSX.MAC   - RUNOFF source file
RUNOFF.MAC   - RUNOFF source file
START.MAC    - RUNOFF source file
RNPRE.MAC    - RUNOFF source prefix file for all systems
RSTS.MAC     - RUNOFF second prefix file for RSTS/E
RUNOFF.RNO   - Source for RUNOFF manual
RNRT11.MAC   - RT11 RUNOFF source file
RNRT1X.MAC   - RT11 RUNOFF optional source file
README.1ST   - This document

