cat << 'EOF'
QMEAN provides three analysis modes: QMEAN, QMEANDisCo, and QMEANBrane.
All modes require the UniClust30 database, while QMEANDisCo additionally
requires the QMEAN Template Library (QMTL) for its scoring.

1) UniClust30 database (required by QMEAN, QMEANDisCo, QMEANBrane)
   ───────────────────────────────────────────────────────────────────────
   You must set the QMEAN_UNICLUST30 environment variable to point to
   your local UniClust30 database directory, which must contain:
     • *_a3m.ffdata
     • *_a3m.ffindex
     • *_hhm.ffdata
     • *_hhm.ffindex
     • *_cs219.ffdata
     • *_cs219.ffindex

   Example (add to ~/.bashrc or ~/.zshrc):
     export QMEAN_UNICLUST30=/path/to/uniclust30/uniclust30_2018_08

   Download UniClust30 from:
     https://uniclust.mmseqs.com/

2) QMEAN Template Library (QMTL) (required only by QMEANDisCo)
   ───────────────────────────────────────────────────────────────────────
   QMTL provides the model/template files needed for DisCo scoring.

   You can download to extract the archive manually from:
     https://swissmodel.expasy.org/repository/download/qmtl/qmtl.tar.bz2

   Example (add to ~/.bashrc or ~/.zshrc):
     export QMEAN_QMTL=${PREFIX}/share/qmean/qmtl

Without these environment variables, `qmean` will exit with an error
indicating which resource is missing.
EOF
