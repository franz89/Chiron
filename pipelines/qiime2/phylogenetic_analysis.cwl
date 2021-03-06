#!/usr/bin/env cwl-runner
cwlVersion: v1.0
label: QIIME2 - Generate a phylogenetic tree
class: Workflow

hints:
  - class: DockerRequirement
    dockerPull: umigs/chiron-qiime2

inputs:
  rep_seqs:
    type: File
outputs:
  rooted_tree:
    type: File
    outputSource: phylogeny_midpoint_root/out_rooted

steps:
  alignment_mafft:
    run:
      class: CommandLineTool
      baseCommand: ["qiime", "alignment", "mafft"]
      inputs:
        rep_seqs:
          inputBinding:
            prefix: --i-sequences
          type: File
        aligned_seqs:
          inputBinding:
            prefix: --o-alignment
          type: string
          default: "aligned-rep-seqs.qza"
      outputs:
        out_align:
          type: File
          outputBinding:
            glob: $(inputs.aligned_seqs)
    in:
      rep_seqs: rep_seqs
    out: [out_align]
  alignment_mask:
    run:
      class: CommandLineTool
      baseCommand: ["qiime", "alignment", "mask"]
      inputs:
        aligned_seqs:
          inputBinding:
            prefix: --i-alignment
          type: File
        masked_seqs:
          inputBinding:
            prefix: --o-masked-alignment
          type: string
          default: "masked-aligned-rep-seqs.qza"
      outputs:
        out_masked:
          type: File
          outputBinding:
            glob: $(inputs.masked_seqs)
    in:
      aligned_seqs: alignment_mafft/out_align
    out: [out_masked]
  phylogeny_fasttree:
    run:
      class: CommandLineTool
      baseCommand: ["qiime", "phylogeny", "fasttree"]
      inputs:
        masked_seqs:
          inputBinding:
            prefix: --i-alignment
          type: File
        tree:
          inputBinding:
            prefix: --o-tree
          type: string
          default: "unrooted-tree.qza"
      outputs:
        out_tree:
          type: File
          outputBinding:
            glob: $(inputs.tree)
    in:
      masked_seqs: alignment_mask/out_masked
    out: [out_tree]
  phylogeny_midpoint_root:
    run:
      class: CommandLineTool
      baseCommand: ["qiime", "phylogeny", "midpoint-root"]
      inputs:
        input_tree:
          inputBinding:
            prefix: --i-tree
          type: File
        rooted_tree:
          inputBinding:
            prefix: --o-rooted-tree
          type: string
          default: "rooted-tree.qza"
      outputs:
        out_rooted:
          type: File
          outputBinding:
            glob: $(inputs.rooted_tree)
    in:
      input_tree: phylogeny_fasttree/out_tree
    out: [out_rooted]
