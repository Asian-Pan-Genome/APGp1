import os
import gzip
import re
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from collections import defaultdict, Counter

# ==================== Configuration ====================
FAI_FILE = "GCF_009914755.1_T2T-CHM13v2.0_genomic_chr.fasta.fai"

# Mapping: folder name -> input vcf filename
VCF_MAP = {
    "SVDSS": "SVDSS/svdss2-minsupp4.vcf.gz",
    "sniffles2": "sniffles2/hg002.align_chm13.vcf.gz",
    "pbsv": "pbsv/hg002.align_chm13.vcf.gz",
    "cuteSV": "cuteSV/cutesv.vcf.gz",
    "Debreak": "Debreak/debreak.vcf.gz",
    "svim": "svim/variants.vcf.gz",
}

# Colors for SVTYPE
SVTYPE_COLORS = {
    'DEL': '#E41A1C',
    'INS': '#377EB8',
    'DUP': '#4DAF4A',
    'INV': '#984EA3',
    'BND': '#FF7F00',
    'OTH': '#999999',
}

# Colors for GT
GT_COLORS = {
    '0/0': '#66C2A5',
    '0/1': '#FC8D62',
    '1/1': '#8DA0CB',
    './.': '#E78AC3',
    'other': '#A6D854',
}

# ==================== Helper Functions ====================

def parse_fai(fai_path):
    """Parse fai file and return ordered list of (chrom, length)."""
    chroms = []
    with open(fai_path) as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) >= 2:
                # fai format: name, length, offset, linebases, linewidth
                chroms.append((parts[0], int(parts[1])))
    return chroms


def parse_info(info_str):
    """Parse VCF INFO field into dict."""
    info = {}
    for item in info_str.split(';'):
        if '=' in item:
            k, v = item.split('=', 1)
            info[k] = v
        else:
            info[item] = True
    return info


def parse_gt(format_str, sample_str):
    """Extract GT from sample column."""
    if not format_str or not sample_str:
        return './.'
    fmt_keys = format_str.split(':')
    samp_vals = sample_str.split(':')
    if len(fmt_keys) != len(samp_vals):
        # try to infer GT from beginning
        return samp_vals[0] if samp_vals else './.'
    for k, v in zip(fmt_keys, samp_vals):
        if k == 'GT':
            return v
    return './.'


def parse_vcf(vcf_path):
    """Parse VCF and return list of records with chrom, pos, svlen, svtype, gt."""
    records = []
    opener = gzip.open if vcf_path.endswith('.gz') else open
    mode = 'rt' if vcf_path.endswith('.gz') else 'r'
    with opener(vcf_path, mode) as f:
        for line in f:
            if line.startswith('#'):
                continue
            parts = line.strip().split('\t')
            if len(parts) < 8:
                continue
            chrom = parts[0]
            pos = int(parts[1])
            info = parse_info(parts[7])
            svtype = info.get('SVTYPE', 'OTH')

            # BND has no meaningful length for length distribution
            svlen = None
            if svtype != 'BND':
                svlen_str = info.get('SVLEN', None)
                if svlen_str is not None:
                    try:
                        svlen = abs(int(svlen_str))
                    except ValueError:
                        svlen = None
                else:
                    # try to estimate from REF/ALT if symbolic alleles
                    ref = parts[3]
                    alt = parts[4]
                    if alt.startswith('<') and alt.endswith('>'):
                        # symbolic allele, no length info
                        # use END if available
                        end_str = info.get('END', None)
                        if end_str:
                            try:
                                svlen = abs(int(end_str) - pos)
                            except ValueError:
                                svlen = None
                        else:
                            svlen = None
                    else:
                        svlen = max(len(alt) - len(ref), len(ref) - len(alt))
                        if svlen == 0:
                            svlen = None
            
            gt = './.'
            if len(parts) >= 10:
                gt = parse_gt(parts[8], parts[9])
            elif len(parts) == 9:
                # Some VCFs might have no FORMAT but sample?
                gt = parse_gt(parts[8], '')
            
            # Normalize svtype
            svtype = svtype.upper()
            if svtype not in SVTYPE_COLORS:
                svtype = 'OTH'
            
            # Normalize GT
            if gt not in GT_COLORS:
                gt = 'other'
            
            records.append({
                'chrom': chrom,
                'pos': pos,
                'svlen': svlen,
                'svtype': svtype,
                'gt': gt,
            })
    return records


def plot_length_distribution(ax_top, ax_bottom, records, title_prefix=""):
    """Plot stacked bar-style histogram of SV lengths in two scales.
    Style adapted from SVIM_plot.py.
    """
    # Group lengths by svtype (skip None lengths, e.g. BND)
    svtype_lengths = defaultdict(list)
    for r in records:
        if r['svlen'] is not None:
            svtype_lengths[r['svtype']].append(r['svlen'])

    svtypes = [s for s in SVTYPE_COLORS.keys() if s in svtype_lengths]
    if not svtypes:
        ax_top.text(0.5, 0.5, "No length data", transform=ax_top.transAxes, ha='center')
        ax_bottom.text(0.5, 0.5, "No length data", transform=ax_bottom.transAxes, ha='center')
        return

    # Sort data by SVTYPE order
    lengths = tuple(svtype_lengths[st] for st in svtypes)
    colors = [SVTYPE_COLORS[st] for st in svtypes]

    # Top: 0-2000, bin width 10
    bins_top = [i for i in range(0, 2001, 10)]
    # Bottom: 0-20000, bin width 100
    bins_bottom = [i for i in range(0, 20001, 100)]

    ax_top.hist(x=lengths,
                bins=bins_top,
                stacked=True,
                histtype='bar',
                color=colors,
                label=svtypes)
    ax_top.set_title(f"{title_prefix} SV Length Distribution (0-2kb)", fontsize=12)
    ax_top.set_xlabel('Length of structural variant')
    ax_top.set_ylabel('Number of variants')
    ax_top.legend(frameon=False, fontsize='small')

    ax_bottom.hist(x=lengths,
                   bins=bins_bottom,
                   stacked=True,
                   histtype='bar',
                   color=colors,
                   label=svtypes,
                   log=True)
    ax_bottom.set_title(f"{title_prefix} SV Length Distribution (0-20kb)", fontsize=12)
    ax_bottom.set_xlabel('Length of structural variant')
    ax_bottom.set_ylabel('Number of variants')
    ax_bottom.legend(frameon=False, fontsize='small')


def plot_genotype_distribution(ax, records, title_prefix=""):
    """Plot grouped bar chart: SVTYPE x GT."""
    # Count by svtype and gt
    counts = defaultdict(lambda: defaultdict(int))
    for r in records:
        counts[r['svtype']][r['gt']] += 1
    
    svtypes = [s for s in SVTYPE_COLORS.keys() if s in counts]
    gts = [g for g in GT_COLORS.keys() if any(g in counts[s] for s in svtypes)]
    if not gts:
        gts = list(GT_COLORS.keys())
    
    x = np.arange(len(svtypes))
    width = 0.8 / len(gts)
    
    for i, gt in enumerate(gts):
        vals = [counts[st].get(gt, 0) for st in svtypes]
        ax.bar(x + i * width, vals, width, label=gt, color=GT_COLORS.get(gt, '#333333'))
    
    ax.set_xticks(x + width * (len(gts) - 1) / 2)
    ax.set_xticklabels(svtypes)
    ax.set_xlabel("SV Type")
    ax.set_ylabel("Count")
    ax.set_title(f"{title_prefix} SV Count by Genotype", fontsize=12)
    ax.legend(title="GT", fontsize=8)


def plot_chromosome_density(ax, records, chroms_info, title_prefix=""):
    """Plot SV density across chromosomes."""
    # chroms_info: list of (chrom, length)
    chrom_dict = {c: l for c, l in chroms_info}
    
    # Filter records to chromosomes in fai
    filtered = [r for r in records if r['chrom'] in chrom_dict]
    
    if not filtered:
        ax.text(0.5, 0.5, "No matching chromosomes", transform=ax.transAxes, ha='center')
        return
    
    # Bin size: 1 Mb
    bin_size = 1_000_000
    
    # Compute cumulative offsets
    cum_offset = {}
    offset = 0
    for chrom, length in chroms_info:
        cum_offset[chrom] = offset
        offset += length
    total_len = offset
    
    # Build global histogram
    n_bins = int(np.ceil(total_len / bin_size))
    global_counts = np.zeros(n_bins)
    
    for r in filtered:
        idx = int((cum_offset[r['chrom']] + r['pos']) / bin_size)
        if 0 <= idx < n_bins:
            global_counts[idx] += 1
    
    bin_edges = np.arange(n_bins + 1) * bin_size
    bin_centers = (bin_edges[:-1] + bin_edges[1:]) / 2
    
    # Plot as bar
    ax.bar(bin_centers, global_counts, width=bin_size, color='steelblue', edgecolor='none')
    
    # Add chromosome boundary lines and labels
    cum = 0
    chrom_labels = []
    chrom_positions = []
    for chrom, length in chroms_info:
        cum += length
        ax.axvline(cum, color='gray', linestyle='--', linewidth=0.5, alpha=0.7)
        chrom_positions.append(cum - length / 2)
        chrom_labels.append(chrom.replace('chr', ''))
    
    ax.set_xticks(chrom_positions)
    ax.set_xticklabels(chrom_labels, fontsize=7)
    ax.set_xlim(0, total_len)
    ax.set_xlabel("Chromosome")
    ax.set_ylabel("SV Count per Mb")
    ax.set_title(f"{title_prefix} SV Density across Chromosomes", fontsize=12)


def process_folder(folder, vcf_file, fai_path, output_dir):
    print(f"Processing {folder} ...")
    records = parse_vcf(vcf_file)
    if not records:
        print(f"  Warning: no records found in {vcf_file}")
        return
    
    chroms_info = parse_fai(fai_path)
    
    fig = plt.figure(figsize=(14, 16))
    gs = gridspec.GridSpec(4, 1, height_ratios=[1, 1, 1, 1], hspace=0.35)
    
    ax_top = fig.add_subplot(gs[0, 0])
    ax_bottom = fig.add_subplot(gs[1, 0])
    ax_gt = fig.add_subplot(gs[2, 0])
    ax_chrom = fig.add_subplot(gs[3, 0])
    
    plot_length_distribution(ax_top, ax_bottom, records, title_prefix=folder)
    plot_genotype_distribution(ax_gt, records, title_prefix=folder)
    plot_chromosome_density(ax_chrom, records, chroms_info, title_prefix=folder)
    
    out_path = os.path.join(output_dir, f"{folder}_sv_visualization.png")
    plt.savefig(out_path, dpi=200, bbox_inches='tight')
    plt.close(fig)
    print(f"  Saved: {out_path}")


def main():
    fai_path = FAI_FILE
    if not os.path.exists(fai_path):
        print(f"FAI file not found: {fai_path}")
        return
    
    for folder, vcf_file in VCF_MAP.items():
        if not os.path.exists(vcf_file):
            print(f"VCF not found, skipping {folder}: {vcf_file}")
            continue
        process_folder(folder, vcf_file, fai_path, folder)


if __name__ == "__main__":
    main()
