#!/usr/bin/perl

# usage
# carregar_lexic_srd_ita.pl n|adj|adv|vblex|cnjadv|pr|top|org|al|ant|pref|ij
# el segon argument indica si es generen paraules en català a partir dels fitxer d'en Jaume Ortolà
# (per defecte 0=no)

# En aquest programa es llegeix el fitxer amb 4 columnes separades per tabuladors amb paraules amb categories tancades
# 1. paraula ita
# 2. categoria gramatical
# 3. paraula srd
# 4. gènere del nom srd (optatiu)
# 6. autor
# El programa genera 2 fitxers per carregar als 2 fitxers de diccionari

use strict;
use utf8;

my $MOT = "liminàrgiu";	# paraula a debugar
#my $MOT = "instrument# de vent";	# paraula a debugar
my $MOT = '';

my $CARREGAR_UNICS = 1;		# carrego les parelles de traduccions que són 1-1
my $CARREGAR_MES1 = 1;		# carrego les parelles de traduccions que són 1-n
my $GEN_ITA = 1;		# generar paraules ita
my $POSAR_MIN_INI = 1;		# convertir en mínúscula la majúscula inicial, si hi és, del mot ita

my $MORF_TRACT = $ARGV[0];
$MORF_TRACT = 'n' unless $MORF_TRACT;
$CARREGAR_MES1 = 1 if $MORF_TRACT eq 'top';

my ($fita, $fsrd, $fbi, $fdixita, $fdixsrd, $fdixbi, $fdixitan, $fdixitaadj, $fdixitaadv);

my $HOME = '/home/hector';
open($fdixita, "$HOME/apertium/apertium-ita/apertium-ita.ita.dix") || die "can't open apertium-ita.ita.dix: $!";
open($fdixitan, "$HOME/apertium/apertium-ita/jaumeortola/ita-noun.txt") || die "can't open ita-noun.txt: $!";
open($fdixitaadj, "$HOME/apertium/apertium-ita/jaumeortola/ita-adj.txt") || die "can't open ita-adj.txt: $!";
open($fdixitaadv, "$HOME/apertium/apertium-ita/jaumeortola/ita-adv.txt") || die "can't open ita-adv.txt: $!";
open($fdixsrd, "$HOME/apertium/apertium-srd/apertium-srd.srd.dix") || die "can't open apertium-srd.srd.dix: $!";
open($fdixbi, "$HOME/apertium/apertium-srd-ita/apertium-srd-ita.srd-ita.dix") || die "can't open apertium-srd-ita.srd-ita.dix: $!";

open($fita, ">f_ita.dix.txt") || die "can't create f_ita.dix.txt: $!";
open($fsrd, ">f_srd.dix.txt") || die "can't create f_srd.dix.txt: $!";
open($fbi, ">f_bi.dix.txt") || die "can't create f_bi.dix.txt: $!";

binmode(STDIN, ":encoding(UTF-8)");
binmode($fdixita, ":encoding(UTF-8)");
binmode($fdixitan, ":encoding(UTF-8)");
binmode($fdixitaadj, ":encoding(UTF-8)");
binmode($fdixitaadv, ":encoding(UTF-8)");
binmode($fdixsrd, ":encoding(UTF-8)");
binmode($fdixbi, ":encoding(UTF-8)");
binmode($fita, ":encoding(UTF-8)");
binmode($fsrd, ":encoding(UTF-8)");
binmode($fbi, ":encoding(UTF-8)");
binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");

my %dix_ita = ();
my %dix_ita_prm = ();
my %dix_srd = ();
my %dix_srd_prm = ();
my %dix_itav = ();
my %dix_itan = ();
my %dix_itan_def = ();
my %dix_itaadj = ();
my %dix_itaadj_def = ();
my %dix_itaadv = ();
my %dix_itaadv_def = ();
my %dix_ita_srd = ();
my %dix_srd_ita = ();
my %entrada_ita_srd = ();
my %entrada_srd_ita = ();
my %entrada_ita_srd_yes = ();
my @data = ();

sub llegir_dix_ortola {
	my ($nfitx, $fitx, $r_struct, $r_struct2) = @_;
	my ($lemma, $par, $morf);

	while (my $linia = <$fitx>) {
		chop $linia;

print "1. fitxer ortola $nfitx, $linia\n" if $MOT && $linia =~ /$MOT/o;
		if ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} else {
print STDERR "Error en llegir_dix_ortola fitxer $nfitx, $linia\n";
			next;
		}
		if ($par =~ /__(.*)$/o) {
			$morf = $1;
		} else {
			die "fitxer ortola $nfitx, $linia, par=$par";
		}
print "2. fitxer ortola $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'cnjadv' && $morf ne 'pr' && $morf ne 'pref' && $morf ne 'ij' && $morf ne 'abbr') {
			print STDERR "llegir_dix_ortola fitxer $nfitx, línia $.: $linia - morf $morf\n";
			next;
		}
print "3. fitxer ortola $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;

		$r_struct->{$morf}{$lemma} = $par;
		$r_struct2->{$morf}{$lemma} = $linia;
print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
	}
print "4. fitxer ortola $nfitx r_struct->{$MORF_TRACT}{$MOT} = $r_struct->{$MORF_TRACT}{$MOT}\n" if $MOT;
}

# llegeixo un monodix
sub llegir_dix {
	my ($nfitx, $fitx, $r_struct, $r_struct_prm) = @_;
	my ($lemma, $par, $prm, $morf);

	while (my $linia = <$fitx>) {
		chop $linia;
#		next if $linia =~ /r="LR"/o;
		next if $linia =~ /<!-- .*<e/o;

print "0. fitxer $nfitx, $linia\n" if $MOT && $linia =~ /$MOT/o;
		next if $linia !~ /__$MORF_TRACT"/o
			&& $linia !~ /__np"/o && ($MORF_TRACT eq 'top' || $MORF_TRACT eq 'ant' || $MORF_TRACT eq 'org' || $MORF_TRACT eq 'al')
			&& $linia !~ /__n"/o && $MORF_TRACT eq 'acr';

#<e lm="relever le gant" a="alanfavre"><i>rel</i><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>le<b/>gant</l><r><g><b/>le<b/>gant</g></r></p></e>

#     <e lm="crever les yeux"><p><l>cr</l><r>cr</r></p><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>les<b/>yeux</l><r><g><b/>les<b/>yeux</g></r></p></e>
#     <e lm="intégrer"><i>int</i><par n="accél/é[R]er__vblex" prm="gr"/></e>
#     <e lm="emprunt" a="joan"><i>emprunt</i><par n="livre__n"/></e>

print "1. fitxer $nfitx, $linia\n" if $MOT && $linia =~ /$MOT/o;
		$prm = '';
# <e lm="syndicat d'initiative"><i>syndicat</i><par n="accessoire__n"/><p><l><b/>d'initiative</l><r><g><b/>d'initiative</g></r></p></e>
		if ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)".*<l>(.*)</l>|o) {
			$lemma = $1;
			$par = $2;
			my $cua = $3;
			$cua =~ s|<b/>| |og;
			my $cap = $lemma;
			$cap =~ s/$cua$//;
			$lemma = $cap . '#' . $cua;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)" prm="([^"]*)"/>|o) {
			$lemma = $1;
			$par = $2;
			$prm = $3;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)">[^<]*<par n="(.*)"/></e>|o) {
#<e lm="ampli">           <par n="/ampli__adj"/></e>
			$lemma = $1;
			$par = $2;
		} else {
			next;
		}
		if ($par =~ /__(.*)$/o) {
			$morf = $1;
		} else {
			die "fitxer $nfitx, $linia, par=$par";
		}
print "2. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;
#		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'cnjadv' && $morf ne 'pr' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
#			next;
#		}
print "3. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;
		if ($morf eq 'np' && ($MORF_TRACT eq 'top' || $MORF_TRACT eq 'ant' || $MORF_TRACT eq 'org' || $MORF_TRACT eq 'al')) {
			if ($par eq 'Afghanistan__np' || $par eq 'Afganistàn__np') {
				$morf = 'top';
			} elsif ($par eq 'Europa__np' || $par eq 'Etiòpia__np') {
				$morf = 'top';
			} elsif ($par eq 'USA__np' || $par eq 'Istados_Unidos__np') {
				$morf = 'top';
			} elsif ($par eq 'Maldive__np' || $par eq 'Is_Pratzas__np') {
				$morf = 'top';
			} elsif ($par eq 'Po__np') {
				$morf = 'hyd';
			} elsif ($par eq 'Loira__np') {
				$morf = 'hyd';
			} elsif ($par eq 'Juan__np' || $par eq 'Antoni__np') {
				$morf = 'ant';
			} elsif ($par eq 'Maria__np') {
				$morf = 'ant';
			} elsif ($par eq 'ABC__np' || $par eq 'Linux__np') {
				$morf = 'al';
			} elsif ($par eq 'Polizia__np' || $par eq 'Wikipedia__np') {
				$morf = 'al';
			} elsif ($par eq 'Giochi_olimpici__np' || $par eq 'Queen__np') {
				$morf = 'al';
			} elsif ($par eq 'Milan__np') {
				$morf = 'org';
			} elsif ($par eq 'Fiat__np') {
				$morf = 'org';
			} elsif ($par eq 'Brigate_Rosse__np' || $par eq 'Natziones_Unides__np') {
				$morf = 'org';
			} else {
				next;
			}
		} elsif ($morf eq 'n' && $MORF_TRACT eq 'acr') {
			if ($par eq 'BBVA__n' || $par eq 'PNB__n') {
				$morf = 'acr';
			} elsif ($par eq 'TV__n') {
				$morf = 'acr';
			} elsif ($par eq 'PIL__n' || $par eq 'kg__n') {
				$morf = 'acr';
			} else {
				next;
			}
		}

		next if $morf ne $MORF_TRACT;

		if ($r_struct->{$morf}{$lemma} && $morf ne 'vblex') {
#			print STDERR "Error llegir_dix $nfitx: lemma $lemma (morf = $morf, par = $par) ja definit com a morf = $morf, par = $r_struct->{$morf}{$lemma}\n"
#				if $r_struct->{$morf}{$lemma} ne $par;
		} else {
			$r_struct->{$morf}{$lemma} = $par;
			$r_struct_prm->{$morf}{$lemma} = $prm if $prm;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $par =~ /vblex/o;
print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
print "r_struct_prm->{$morf}{$lemma} = $r_struct_prm->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
		}
	}
print "4. fitxer $nfitx r_struct->{$MORF_TRACT}{$MOT} = $r_struct->{$MORF_TRACT}{$MOT}\n" if $MOT;
}

# llegeixo el fitxer bilingüe: n, adj, adv, abbr
# guardo les traduccions etiquetades com a yes a r_struct_yes per a no repetir-les en generar noves entrades
sub llegir_bidix {
	my ($fitx, $r_struct_rl, $r_struct_lr, $r_struct_yes) = @_;
	my ($lemma_srd, $lemma_ita, $morf, $morf2, $dir);

#      <e><p><l>derrota<s n="n"/><s n="f"/></l><r>derrota<s n="n"/><s n="f"/></r></p></e>
#      <e><p><l>proper<s n="adj"/></l><r>imbeniente<s n="adj"/></r></p><par n="GD_mf"/></e>
#      <e r="LR"><p><l>aqueix<s n="prn"/><s n="tn"/></l><r>custu<s n="prn"/><s n="tn"/></r></p></e>
#      <e><p><l>pacient<s n="n"/></l><r>malàidu<s n="n"/></r></p><par n="mf_GD"/></e>
#      <e><p><l>arribar<g><b/>a</g><s n="vblex"/></l><r>arribare<g><b/>a</g><s n="vblex"/></r></p></e>
	while (my $linia = <$fitx>) {
next if $linia !~ /$MORF_TRACT/o;
		chop $linia;
		$linia =~ s|<b/>| |og;
		$linia =~ s|<g>|#|og;
		$linia =~ s|</g>||og;
print "1. fitxer bidix, $linia\n" if $MOT && $linia =~ /$MOT/o;

#<e>       <p><l>Piémont<s n="np"/><s n="top"/><s n="m"/><s n="sg"/></l><r>Piemont<s n="np"/><s n="top"/><s n="m"/><s n="sg"/></r></p></e>
		$linia =~ s|np"/><s n="top|top|og;
		$linia =~ s|np"/><s n="ant|ant|og;
		$linia =~ s|np"/><s n="org|org|og;
		$linia =~ s|np"/><s n="al|al|og;
		$linia =~ s|n"/><s n="acr|acr|og;

		if ($linia =~ m|<e> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e vr="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e c="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_srd = $1;
			$morf = $2;
			$lemma_ita = $3;
			$dir = 'bi';
		} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="LR" c="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="LR" a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*" r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_srd = $1;
			$morf = $2;
			$lemma_ita = $3;
			$dir = 'lr';
		} elsif ($linia =~ m|<e r="RL"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="RL" c="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="RL" a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*" r="RL"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_srd = $1;
			$morf = $2;
			$lemma_ita = $3;
			$dir = 'rl';
		} elsif ($linia =~ m|<e i="yes"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e i="yes" c="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e i="yes" a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*" i="yes"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_srd = $1;
			$morf = $2;
			$lemma_ita = $3;
			$dir = 'yes';
		} elsif ($linia =~ m|<e|o && $. > 140) {
#			print STDERR "Error lectura bidix en l. $.: $linia\n";
		} else {
			next;
		}
#		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'cnjadv' && $morf ne 'pr' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
#			next;
#		}
next if $morf ne $MORF_TRACT;

print "3. fitxer bidix, $linia, morf=$morf, lemma_srd = $lemma_srd, lemma_ita = $lemma_ita\n" if $MOT && $linia =~ /$MOT/o;

		push @{$r_struct_rl->{$morf}{$lemma_ita}}, $lemma_srd if $dir eq 'bi' || $dir eq 'lr';
		push @{$r_struct_lr->{$morf}{$lemma_srd}}, $lemma_ita if $dir eq 'bi' || $dir eq 'rl';
		$r_struct_yes->{$morf}{$lemma_ita}{$lemma_srd} = 1 if $dir eq 'yes';
print "r_struct_yes->{$morf}{$lemma_ita}{$lemma_srd} = $r_struct_yes->{$morf}{$lemma_ita}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "r_struct_rl->{$morf}{$lemma_ita}[$#{$r_struct_rl->{$morf}{$lemma_ita}}] = $r_struct_rl->{$morf}{$lemma_ita}[$#{$r_struct_rl->{$morf}{$lemma_ita}}]\n" if $MOT && $lemma_ita =~ /$MOT/o; # si es decomenta, ha de ser nomës per a proves, sense carregar res (els 'exists' posteriors peten per culpa d'això)
#print "r_struct_lr->{$morf}{$lemma_srd}[$#{$r_struct_lr->{$morf}{$lemma_srd}}] = $r_struct_lr->{$morf}{$lemma_srd}[$#{$r_struct_lr->{$morf}{$lemma_srd}}]\n" if $MOT && $lemma_srd =~ /$MOT/o; # si es decomenta, ha de ser nomës per a proves, sense carregar res (els 'exists' posteriors peten per culpa d'això)
	}
}

sub crear_g_ita {
	my ($lemma_ita, $gram_ita, $autor) = @_;
#print "crear_g_ita($lemma_ita, $gram_ita)\n";
	my ($cap, $cua);
	my $a = " a=\"$autor\"" if $autor;
#	couper# en morceux <vblex>
#     <e lm="crever les yeux"><p><l>cr</l><r>cr</r></p><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>les<b/>yeux</l><r><g><b/>les<b/>yeux</g></r></p></e>
	if ($lemma_ita =~ /#/o) {
		$cap = $`;
		$cua = $';
	} else {
		print STDERR "Error en crear_g_ita($lemma_ita, $gram_ita)\n";
	}
	unless ($dix_ita{$gram_ita}{$cap}) {
		print STDERR "1. Falta ita $cap <$gram_ita> (0)\n";
		return 1;
	}
	$lemma_ita =~ s/#//o;
	$cua = " $cua";
	$cua =~ s/ +/ /og;
	$cua =~ s/ $//o;
	$cua =~ s/ /<b\/>/og;
	my $cua_par = $dix_ita{$gram_ita}{$cap};
	if ($cua_par =~ m|/|o) {
		$cua_par =~ s/__vblex$//o;
		$cua_par =~ s/__n$//o;
		$cua_par =~ s/^.*\///o;
		$cua_par =~ s/\[.*\]//o;
	} else {
		$cua_par = '';
	}
	my $lcua_par = length($cua_par) + length($dix_ita_prm{$gram_ita}{$cap});
	my $arrel = substr($cap, 0, length($cap)-$lcua_par);
#printf "$arrel, $cua_par, $lcua_par\n";
	if ($dix_ita_prm{$gram_ita}{$cap}) {
		printf $fita "<e lm=\"%s\"$a><p><l>%s</l><r>%s</r></p><par n=\"%s\" prm=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
			$lemma_ita, $arrel, $arrel, $dix_ita{$gram_ita}{$cap}, $dix_ita_prm{$gram_ita}{$cap}, $cua, $cua;
	} else {
		if ($lemma_ita =~ / à$/o) {
#    <e lm="consister à" r="LR"><i>consist</i><par n="abaiss/er__vblex"/><p><l><b/>à</l><r><g><b/>à</g></r></p></e>
#    <e lm="consister à" r="RL"><i>consist</i><par n="abaiss/er__vblex"/><p><l><b/><a/>à</l><r><g><b/>à</g></r></p></e>
			my $cua2 = $cua;
			$cua2 =~ s/à$/<a\/>à/o;
			printf $fita "<e lm=\"%s\" r=\"LR\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_ita, $arrel, $dix_ita{$gram_ita}{$cap}, $cua, $cua;
			printf $fita "<e lm=\"%s\" r=\"RL\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_ita, $arrel, $dix_ita{$gram_ita}{$cap}, $cua2, $cua;
		} elsif ($lemma_ita =~ / de$/o) {
#    <e lm="convenir verbalement de" r="LR"><i>conv</i><par n="appart/enir__vblex"/><p><l><b/>verbalement<b/>de</l><r><g><b/>verbalement<b/>de</g></r></p></e>
#    <e lm="convenir verbalement de" r="RL"><i>conv</i><par n="appart/enir__vblex"/><p><l><b/>verbalement<b/><a/>de</l><r><g><b/>verbalement<b/>de</g></r></p></e>
			my $cua2 = $cua;
			$cua2 =~ s/de$/<a\/>de/o;
			printf $fita "<e lm=\"%s\" r=\"LR\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_ita, $arrel, $dix_ita{$gram_ita}{$cap}, $cua, $cua;
			printf $fita "<e lm=\"%s\" r=\"RL\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_ita, $arrel, $dix_ita{$gram_ita}{$cap}, $cua2, $cua;
		} else {
			printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_ita, $arrel, $dix_ita{$gram_ita}{$cap}, $cua, $cua;
		}
	}
	return 0;
}

# retorna 0 ssi la cadena no és a la llista
sub crear_g_srd {
	my ($lemma_srd, $gram_srd, $autor) = @_;
#print "crear_g_srd($lemma_srd, $gram_srd)\n";
	my ($cap, $cua);
	my $a = " a=\"$autor\"" if $autor;
#	couper# en morceux <vblex>
#     <e lm="crever les yeux"><p><l>cr</l><r>cr</r></p><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>les<b/>yeux</l><r><g><b/>les<b/>yeux</g></r></p></e>
	if ($lemma_srd =~ /#/o) {
		$cap = $`;
		$cua = $';
	} else {
		print STDERR "Error en crear_g_srd($lemma_srd, $gram_srd)\n";
	}
	unless ($dix_srd{$gram_srd}{$cap}) {
		print STDERR "1. Falta srd $cap <$gram_srd> (0)\n";
		return 1;
	}
	$lemma_srd =~ s/#//o;
	$cua = " $cua";
	$cua =~ s/ +/ /og;
	$cua =~ s/ $//o;
	$cua =~ s/ /<b\/>/og;
	my $cua_par = $dix_srd{$gram_srd}{$cap};
	if ($cua_par =~ m|/|o) {
		$cua_par =~ s/__vblex$//o;
		$cua_par =~ s/__n$//o;
		$cua_par =~ s/^.*\///o;
		$cua_par =~ s/\[.*\]//o;
	} else {
		$cua_par = '';
	}
	my $lcua_par = length($cua_par) + length($dix_srd_prm{$gram_srd}{$cap});
	my $arrel = substr($cap, 0, length($cap)-$lcua_par);
#printf "$arrel, $cua_par, $lcua_par\n";
	if ($dix_srd_prm{$gram_srd}{$cap}) {
		printf $fsrd "<e lm=\"%s\"$a><p><l>%s</l><r>%s</r></p><par n=\"%s\" prm=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
			$lemma_srd, $arrel, $arrel, $dix_srd{$gram_srd}{$cap}, $dix_srd_prm{$gram_srd}{$cap}, $cua, $cua;
	} else {
		if ($lemma_srd =~ / a$/o) {
#    <e lm="consister à" r="LR"><i>consist</i><par n="abaiss/er__vblex"/><p><l><b/>à</l><r><g><b/>à</g></r></p></e>
#    <e lm="consister à" r="RL"><i>consist</i><par n="abaiss/er__vblex"/><p><l><b/><a/>à</l><r><g><b/>à</g></r></p></e>
			my $cua2 = $cua;
			$cua2 =~ s/a$/<a\/>a/o;
			printf $fsrd "<e lm=\"%s\" r=\"LR\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_srd, $arrel, $dix_srd{$gram_srd}{$cap}, $cua, $cua;
			printf $fsrd "<e lm=\"%s\" r=\"RL\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_srd, $arrel, $dix_srd{$gram_srd}{$cap}, $cua2, $cua;
		} elsif ($lemma_srd =~ / de$/o) {
#    <e lm="convenir verbalement de" r="LR"><i>conv</i><par n="appart/enir__vblex"/><p><l><b/>verbalement<b/>de</l><r><g><b/>verbalement<b/>de</g></r></p></e>
#    <e lm="convenir verbalement de" r="RL"><i>conv</i><par n="appart/enir__vblex"/><p><l><b/>verbalement<b/><a/>de</l><r><g><b/>verbalement<b/>de</g></r></p></e>
			my $cua2 = $cua;
			$cua2 =~ s/de$/<a\/>de/o;
			printf $fsrd "<e lm=\"%s\" r=\"LR\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_srd, $arrel, $dix_srd{$gram_srd}{$cap}, $cua, $cua;
			printf $fsrd "<e lm=\"%s\" r=\"RL\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_srd, $arrel, $dix_srd{$gram_srd}{$cap}, $cua2, $cua;
		} else {
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_srd, $arrel, $dix_srd{$gram_srd}{$cap}, $cua, $cua;
		}
	}
	return 0;
}

# retorna 0 ssi la cadena no és a la llista
sub is_in {
	my ($r_list, $string) = @_;

	foreach my $r (@$r_list) {
		return 1 if $r eq $string;
	}
	return 0;
}

sub escriure_srd_adj {
	my ($lemma_srd, $a) = @_;
#print "escriure_srd_adj pendent\n";
$a =~ s/"$/\/automàticu"/ if $a;
	if ($lemma_srd =~ /^de /o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/ /<b\/>/og;
		printf $fsrd "<e r=\"RL\" lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'matessi__adj';
		$dix_srd{adj}{$lemma_srd} = 'matessi__adj';
		return 1;
	} elsif ($lemma_srd =~ /^a /o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/ /<b\/>/og;
		printf $fsrd "<e r=\"RL\" lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'matessi__adj';
		$dix_srd{adj}{$lemma_srd} = 'matessi__adj';
		return 1;
	} elsif ($lemma_srd =~ /^in /o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/ /<b\/>/og;
		printf $fsrd "<e r=\"RL\" lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'matessi__adj';
		$dix_srd{adj}{$lemma_srd} = 'matessi__adj';
		return 1;
	} elsif ($lemma_srd =~ / /o) {
		return 0;
	} elsif ($lemma_srd =~ /cu$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/cu$//o;
		printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'linguìsti/cu__adj';
		$dix_srd{adj}{$lemma_srd} = 'linguìsti/cu__adj';
		return 1;
	} elsif ($lemma_srd =~ /u$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/u$//o;
		printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'frantzes/u__adj';
		$dix_srd{adj}{$lemma_srd} = 'frantzes/u__adj';
		return 1;
	} elsif ($lemma_srd =~ /i$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/i$//o;
		printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'banduler/i__adj';
		$dix_srd{adj}{$lemma_srd} = 'banduler/i__adj';
		return 1;
	} elsif ($lemma_srd =~ /dore$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/e$//o;
		printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'cunservador/e__adj';
		$dix_srd{adj}{$lemma_srd} = 'cunservador/e__adj';
		return 1;
	} elsif ($lemma_srd =~ /nte$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/e$//o;
		printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'fàtzil/e__adj';
		$dix_srd{adj}{$lemma_srd} = 'fàtzil/e__adj';
		return 1;
	} elsif ($lemma_srd =~ /[ai]le$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/e$//o;
		printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'fàtzil/e__adj';
		$dix_srd{adj}{$lemma_srd} = 'fàtzil/e__adj';
		return 1;
	} elsif ($lemma_srd =~ /are$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/e$//o;
		printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'fàtzil/e__adj';
		$dix_srd{adj}{$lemma_srd} = 'fàtzil/e__adj';
		return 1;
	} elsif ($lemma_srd =~ /ista$/o) {
		my $stem_srd = $lemma_srd;
		printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'meda__adj';
		$dix_srd{adj}{$lemma_srd} = 'meda__adj';
		return 1;
	} else {
		return 0;
	}
}

sub escriure_srd_n {
	my ($lemma_srd, $par_ita, $a) = @_;
#print "escriure_srd_adj pendent\n";
	return 0 if $lemma_srd =~ / /o;
$a =~ s/"$/\/automàticu"/ if $a;

	my $genere;
	if ($lemma_srd =~ /ista$/o) {
		$genere = 'mf';
	} elsif ($lemma_srd =~ /a$/o) {
		$genere = 'f';
	} elsif ($lemma_srd =~ /ade$/o) {
		$genere = 'f';
	} elsif ($par_ita eq 'cas/a__n'
		|| $par_ita eq 'abbreviazion/e__n'
		|| $par_ita eq 'effigi/e__n'
		|| $par_ita eq 'al/a__n'
		|| $par_ita eq 'favela__n'
		|| $par_ita eq 'tasc/a__n'
		|| $par_ita eq 'alzatacc/ia__n'
		|| $par_ita eq 'chance__n'
		|| $par_ita eq 'abilità__n'
		) {
		$genere = 'f';
	} elsif ($par_ita eq 'abbain/o__n'
		|| $par_ita eq 'abat/e__n'
		|| $par_ita eq 'abbagli/o__n'
		|| $par_ita eq 'affaire__n'
		|| $par_ita eq 'autom/a__n'
		|| $par_ita eq 'kilowattor/a__n'
		|| $par_ita eq 'corp/us__n'
		|| $par_ita eq 'fung/o__n'
		|| $par_ita eq 'hipp/y__n'
		|| $par_ita eq 'secc/o__n'
		|| $par_ita eq 'anima/l__n'
		|| $par_ita eq 'albatros__n'
		) {
		$genere = 'm';
	} elsif ($par_ita eq 'bambin/o__n'
		|| $par_ita eq 'tedesc/o__n'
		|| $par_ita eq 'astrolog/o__n'
		|| $par_ita eq 'amic/o__n'
		|| $par_ita eq 'segretari/o__n'
		|| $par_ita eq 'mugnai/o__n'
		|| $par_ita eq 'cec/o__n'
		|| $par_ita eq 'suicid/a__n'
		|| $par_ita eq 'agricolt/ore__n'
		|| $par_ita eq 'aggre/ssore__n'
		|| $par_ita eq 'difen/sore__n'
		|| $par_ita eq 'oppr/essore__n'
		|| $par_ita eq 'infermier/e__n'
		|| $par_ita eq 'ca/ne__n'
		|| $par_ita eq 'baron/e__n'
		|| $par_ita eq 're__n'
		|| $par_ita eq 'zar__n'
		|| $par_ita eq 'ero/e__n'
		|| $par_ita eq 'vicer/é__n'
		|| $par_ita eq 'belg/a__n'
		|| $par_ita eq 'colleg/a__n'
		|| $par_ita eq 'd/io__n'
		|| $par_ita eq 'duc/a__n'
		|| $par_ita eq 'poet/a__n'
		|| $par_ita eq 'albanes/e__n' 
		|| $par_ita eq 'sucid/a__n' 
		|| $par_ita eq 'monarc/a__n') {
		$genere = 'mf';
	} else {
		return 0;
	}

	if ($genere eq 'm') {
		if ($lemma_srd =~ /u$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/u$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'àbac/u__n';
			$dix_srd{n}{$lemma_srd} = 'àbac/u__n';
			return 1;
		} elsif ($lemma_srd =~ /us$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/us$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'temp/us__n';
			$dix_srd{n}{$lemma_srd} = 'temp/us__n';
			return 1;
		} else {
			my $stem_srd = $lemma_srd;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'pane__n';
			$dix_srd{n}{$lemma_srd} = 'pane__n';
			return 1;
		}
	} elsif ($genere eq 'f') {
		if ($lemma_srd =~ /e$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/e$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'region/e__n';
			$dix_srd{n}{$lemma_srd} = 'region/e__n';
			return 1;
		} elsif ($lemma_srd =~ /èntzia$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/èntzia$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'difer/èntzia__n';
			$dix_srd{n}{$lemma_srd} = 'difer/èntzia__n';
			return 1;
		} elsif ($lemma_srd =~ /àntzia$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/àntzia$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'import/àntzia__n';
			$dix_srd{n}{$lemma_srd} = 'import/àntzia__n';
			return 1;
		} else {
			my $stem_srd = $lemma_srd;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'mesa__n';
			$dix_srd{n}{$lemma_srd} = 'mesa__n';
			return 1;
		}
	} elsif ($genere eq 'mf') {
		if ($lemma_srd =~ /u$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/u$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'amig/u__n';
			$dix_srd{n}{$lemma_srd} = 'amig/u__n';
			return 1;
		} elsif ($lemma_srd =~ /ese$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/e$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'albanes/e__n';
			$dix_srd{n}{$lemma_srd} = 'albanes/e__n';
			return 1;
		} elsif ($lemma_srd =~ /ore$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/e$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'traballador/e__n';
			$dix_srd{n}{$lemma_srd} = 'traballador/e__n';
			return 1;
		} elsif ($lemma_srd =~ /a$/o) {
			my $stem_srd = $lemma_srd;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'dentista__n';
			$dix_srd{n}{$lemma_srd} = 'dentista__n';
			return 1;
		} elsif ($lemma_srd =~ /i$/o) {
			my $stem_srd = $lemma_srd;
			$stem_srd =~ s/i$//og;
			printf $fsrd "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'ingegner/i__n';
			$dix_srd{n}{$lemma_srd} = 'ingegner/i__n';
			return 1;
		}
	}
}

sub escriure_srd_vblex {
	my ($lemma_srd, $a) = @_;
#print "escriure_srd_vblex pendent\n";
$a =~ s/"$/\/automàticu"/ if $a;

	if ($lemma_srd =~ /[cg]are$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/are$//o;
		printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'seg/are__vblex';
		$dix_srd{vblex}{$lemma_srd} = 1;
		return 1;
	} elsif ($lemma_srd =~ /[cg]iare$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/iare$//o;
		printf $fsrd "<e lm=\"%s\"$a>    <p><l>%s</l>   <r>%s</r></p><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $lemma_srd, 'apog/iare__vblex';
		$stem_srd =~ s/a([cg])$/à\1xxxx/o;	# xxxx per aturar les substitucions següents
		$stem_srd =~ s/e([cg])$/è\1xxxx/o;
		$stem_srd =~ s/i([cg])$/ì\1xxxx/o;
		$stem_srd =~ s/o([cg])$/ò\1xxxx/o;
		$stem_srd =~ s/u([cg])$/ù\1xxxx/o;
		$stem_srd =~ s/xxxx$//o;
		printf $fsrd "<e lm=\"%s\"$a>    <p><l>%s</l>   <r>%s</r></p><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $lemma_srd, 'apòg/io__vblex';
		$dix_srd{vblex}{$lemma_srd} = 1;
		return 1;
	} elsif ($lemma_srd =~ /i[^aeiou]*are$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/are$//o;
		printf $fsrd "<e lm=\"%s\"$a>    <p><l>%s</l>   <r>%s</r></p><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $lemma_srd, 'vigil/are__vblex';
		$stem_srd =~ s/a([^aeiou]*)i([^aeiou]*)$/à\1i\2xxxx/o;
		$stem_srd =~ s/e([^aeiou]*)i([^aeiou]*)$/è\1i\2xxxx/o;
		$stem_srd =~ s/i([^aeiou]*)i([^aeiou]*)$/ì\1i\2xxxx/o;
		$stem_srd =~ s/o([^aeiou]*)i([^aeiou]*)$/ò\1i\2xxxx/o;
		$stem_srd =~ s/u([^aeiou]*)i([^aeiou]*)$/ù\1i\2xxxx/o;
		$stem_srd =~ s/xxxx$//o;
		printf $fsrd "<e lm=\"%s\"$a>    <p><l>%s</l>   <r>%s</r></p><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $lemma_srd, 'vìgil/o__vblex';
		$dix_srd{vblex}{$lemma_srd} = 1;
		return 1;
	} elsif ($lemma_srd =~ /are$/o) {
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s/are$//o;
		printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'cant/are__vblex';
		$dix_srd{vblex}{$lemma_srd} = 1;
		return 1;
	} else {
		return 0;
	}
}

sub escriure_bidix_acr {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor) = @_;

print "escriure_bidix_acr ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
	my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
print "1. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "1. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
	my $a = " a=\"$autor\"" if $autor;
	if ($par_ita eq 'BBVA__n' && $par_srd eq 'PNB__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'TV__n' && $par_srd eq 'TV__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'PIL__n' && $par_srd eq 'kg__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sp\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sp\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} else {
print "2. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "2. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print STDERR "No hi ha regla per a escriure_bidix_acr: par_ita = $par_ita ($lemma_ita) par_srd = $par_srd ($lemma_srd)\n";
	}
}

sub escriure_bidix_org {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor) = @_;

print "escriure_bidix_org ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
	my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
print "1. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "1. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
	my $a = " a=\"$autor\"" if $autor;
	if ($par_ita eq 'Milan__np' && $par_srd eq 'Milan__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"org\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"org\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'Fiat__np' && $par_srd eq 'Fiat__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"org\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"org\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'Brigate_Rosse__np' && $par_srd eq 'Natziones_Unides__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"org\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"np\"/><s n=\"org\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} else {
print "2. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "2. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print STDERR "No hi ha regla per a escriure_bidix_org: par_ita = $par_ita ($lemma_ita) par_srd = $par_srd ($lemma_srd)\n";
	}
}

sub escriure_bidix_al {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor) = @_;

print "escriure_bidix_al ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
	my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
print "1. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "1. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
	my $a = " a=\"$autor\"" if $autor;
	if ($par_ita eq 'ABC__np' && $par_srd eq 'Linux__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"al\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"al\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'Polizia__np' && $par_srd eq 'Wikipedia__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"al\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"al\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'Giochi_olimpici__np' && $par_srd eq 'Queen__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"al\"/><s n=\"m\"/><s n=\"pl\"/></l><r>%s<s n=\"np\"/><s n=\"al\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} else {
print "2. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "2. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print STDERR "No hi ha regla per a escriure_bidix_al: par_ita = $par_ita ($lemma_ita) par_srd = $par_srd ($lemma_srd)\n";
	}
}

sub escriure_bidix_ant {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor) = @_;

print "escriure_bidix_ant ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
	my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
print "1. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "1. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
	my $a = " a=\"$autor\"" if $autor;
	if ($par_ita eq 'Juan__np' && $par_srd eq 'Antoni__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'Maria__np' && $par_srd eq 'Maria__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} else {
print "2. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "2. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print STDERR "No hi ha regla per a escriure_bidix_ant: par_ita = $par_ita ($lemma_ita) par_srd = $par_srd ($lemma_srd)\n";
	}
}

sub escriure_bidix_top {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor) = @_;

print "escriure_bidix_top ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
	my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
print "1. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "1. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
	my $a = " a=\"$autor\"" if $autor;
	if ($par_ita eq 'Afghanistan__np' || $par_srd eq 'Afganistàn__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'Europa__np' || $par_srd eq 'Etiòpia__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'USA__np' || $par_srd eq 'Istados_Unidos__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"pl\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'Maldive__np' || $par_srd eq 'Is_Pratzas__np') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} else {
print "2. dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print "2. dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
print STDERR "No hi ha regla per a escriure_bidix_top: par_ita = $par_ita ($lemma_ita) par_srd = $par_srd ($lemma_srd)\n";
	}
}

sub escriure_bidix_n {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor) = @_;

print "escriure_bidix_n ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, <$lr_rl>, $autor)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "escriure_bidix_n ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor)\n" if $lemma_srd eq $MOT || $lemma_ita =~ /musique/o;
#print "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
	if ($lemma_ita =~ /#/o) {
		my $x = $lemma_ita;
#		$x =~ s/#//;
		$par_ita = $dix_ita{$morf_ita}{$x};
	}
	my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
	if ($lemma_srd =~ /#/o) {
		my $x = $lemma_srd;
#		$x =~ s/#//;
		$par_srd = $dix_srd{$morf_srd}{$x};
	}
	my $a = " a=\"$autor\"" if $autor;
	if (($par_ita eq 'cas/a__n'
		|| $par_ita eq 'abbreviazion/e__n'
		|| $par_ita eq 'effigi/e__n'
		|| $par_ita eq 'al/a__n'
		|| $par_ita eq 'favela__n'
		|| $par_ita eq 'tasc/a__n'
		|| $par_ita eq 'alzatacc/ia__n'
		|| $par_ita eq 'chance__n')
			&& ($par_srd eq 'mesa__n'
			|| $par_srd eq 'import/àntzia__n'
			|| $par_srd eq 'difer/èntzia__n'
			|| $par_srd eq 'region/e__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'cas/a__n'
		|| $par_ita eq 'abbreviazion/e__n'
		|| $par_ita eq 'effigi/e__n'
		|| $par_ita eq 'al/a__n'
		|| $par_ita eq 'favela__n'
		|| $par_ita eq 'tasc/a__n'
		|| $par_ita eq 'alzatacc/ia__n'
		|| $par_ita eq 'chance__n')
			&& ($par_srd eq 'àbac/u__n'
			|| $par_srd eq 'temp/us__n'
			|| $par_srd eq 'pane__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'abilità__n'
			&& ($par_srd eq 'mesa__n'
			|| $par_srd eq 'import/àntzia__n'
			|| $par_srd eq 'difer/èntzia__n'
			|| $par_srd eq 'region/e__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'albatros__n'
			&& ($par_srd eq 'àbac/u__n'
			|| $par_srd eq 'temp/us__n'
			|| $par_srd eq 'pane__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'cas/a__n'
		|| $par_ita eq 'abbreviazion/e__n'
		|| $par_ita eq 'effigi/e__n'
		|| $par_ita eq 'al/a__n'
		|| $par_ita eq 'favela__n'
		|| $par_ita eq 'tasc/a__n'
		|| $par_ita eq 'alzatacc/ia__n'
		|| $par_ita eq 'chance__n')
		&& $par_srd eq 'vacances__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"ND_pl\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'cas/a__n'
		|| $par_ita eq 'abbreviazion/e__n'
		|| $par_ita eq 'effigi/e__n'
		|| $par_ita eq 'al/a__n'
		|| $par_ita eq 'favela__n'
		|| $par_ita eq 'tasc/a__n'
		|| $par_ita eq 'alzatacc/ia__n'
		|| $par_ita eq 'chance__n')
		&& $par_srd eq 'personnel__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'abbain/o__n' && $par_srd eq 'personnel__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'bambin/o__n'
		|| $par_ita eq 'tedesc/o__n'
		|| $par_ita eq 'astrolog/o__n'
		|| $par_ita eq 'amic/o__n'
		|| $par_ita eq 'segretari/o__n'
		|| $par_ita eq 'mugnai/o__n'
		|| $par_ita eq 'cec/o__n'
		|| $par_ita eq 'suicid/a__n'
		|| $par_ita eq 'agricolt/ore__n'
		|| $par_ita eq 'aggre/ssore__n'
		|| $par_ita eq 'difen/sore__n'
		|| $par_ita eq 'oppr/essore__n'
		|| $par_ita eq 'infermier/e__n'
		|| $par_ita eq 'ca/ne__n'
		|| $par_ita eq 'baron/e__n'
		|| $par_ita eq 're__n'
		|| $par_ita eq 'zar__n'
		|| $par_ita eq 'ero/e__n'
		|| $par_ita eq 'vicer/é__n'
		|| $par_ita eq 'belg/a__n'
		|| $par_ita eq 'colleg/a__n'
		|| $par_ita eq 'd/io__n'
		|| $par_ita eq 'duc/a__n'
		|| $par_ita eq 'poet/a__n')
		&& ($par_srd eq 'amig/u__n'
			|| $par_srd eq 'traballador/e__n'
			|| $par_srd eq 'ingegner/i__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'bambin/o__n'
		|| $par_ita eq 'tedesc/o__n'
		|| $par_ita eq 'astrolog/o__n'
		|| $par_ita eq 'amic/o__n'
		|| $par_ita eq 'segretari/o__n'
		|| $par_ita eq 'mugnai/o__n'
		|| $par_ita eq 'cec/o__n'
		|| $par_ita eq 'suicid/a__n'
		|| $par_ita eq 'agricolt/ore__n'
		|| $par_ita eq 'aggre/ssore__n'
		|| $par_ita eq 'difen/sore__n'
		|| $par_ita eq 'oppr/essore__n'
		|| $par_ita eq 'infermier/e__n'
		|| $par_ita eq 'ca/ne__n'
		|| $par_ita eq 'baron/e__n'
		|| $par_ita eq 're__n'
		|| $par_ita eq 'zar__n'
		|| $par_ita eq 'ero/e__n'
		|| $par_ita eq 'vicer/é__n'
		|| $par_ita eq 'belg/a__n'
		|| $par_ita eq 'colleg/a__n'
		|| $par_ita eq 'd/io__n'
		|| $par_ita eq 'duc/a__n'
		|| $par_ita eq 'poet/a__n')
		&& ($par_srd eq 'albanes/e__n' || $par_srd eq 'dentista__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'albanes/e__n' 
		|| $par_ita eq 'suicid/a__n'
		|| $par_ita eq 'monarc/a__n')
		&& ($par_srd eq 'albanes/e__n' || $par_srd eq 'dentista__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'albanes/e__n' 
		|| $par_ita eq 'suicid/a__n'
		|| $par_ita eq 'monarc/a__n')
		&& ($par_srd eq 'amig/u__n'
			|| $par_srd eq 'traballador/e__n'
			|| $par_srd eq 'ingegner/i__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'abbain/o__n'
		|| $par_ita eq 'abat/e__n'
		|| $par_ita eq 'abbagli/o__n'
		|| $par_ita eq 'affaire__n'
		|| $par_ita eq 'autom/a__n'
		|| $par_ita eq 'kilowattor/a__n'
		|| $par_ita eq 'corp/us__n'
		|| $par_ita eq 'fung/o__n'
		|| $par_ita eq 'hipp/y__n'
		|| $par_ita eq 'secc/o__n'
		|| $par_ita eq 'anima/l__n')
			&& ($par_srd eq 'àbac/u__n'
			|| $par_srd eq 'temp/us__n'
			|| $par_srd eq 'pane__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'abbain/o__n'
		|| $par_ita eq 'abat/e__n'
		|| $par_ita eq 'abbagli/o__n'
		|| $par_ita eq 'affaire__n'
		|| $par_ita eq 'autom/a__n'
		|| $par_ita eq 'kilowattor/a__n'
		|| $par_ita eq 'corp/us__n'
		|| $par_ita eq 'fung/o__n'
		|| $par_ita eq 'hipp/y__n'
		|| $par_ita eq 'secc/o__n'
		|| $par_ita eq 'anima/l__n')
			&& ($par_srd eq 'mesa__n'
			|| $par_srd eq 'import/àntzia__n'
			|| $par_srd eq 'difer/èntzia__n'
			|| $par_srd eq 'region/e__n')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'argent__n'
		|| $par_ita eq 'personnel__n')
			&& $par_srd eq 'personnel__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'argent__n'
		|| $par_ita eq 'personnel__n')
			&& $par_srd eq 'sêf__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'personnel_n' && $par_srd eq 'personnel__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'soif__n' && $par_srd eq 'sêf__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'abords__n' && $par_srd eq 'alentôrns__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'abords__n'&& $par_srd eq 'vacances__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'vacances__n' && $par_srd eq 'alentôrns__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'vacances__n'&& $par_srd eq 'vacances__n') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} else {
		print STDERR "No hi ha regla per a escriure_bidix_n: par_ita = $par_ita ($lemma_ita) par_srd = $par_srd ($lemma_srd)\n";
print "No hi ha regla per a escriure_bidix_n: par_ita = $par_ita ($lemma_ita) par_srd = $par_srd ($lemma_srd)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print STDERR "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	}
}

sub escriure_bidix_adj {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor) = @_;

print "escriure_bidix_adj ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
	my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
	my $a = " a=\"$autor\"" if $autor;
	if (($par_ita eq 'cosiddett/o__adj'	# sense sup
		|| $par_ita eq 'suicid/a__adj'
		|| $par_ita eq 'acconc/io__adj'
		|| $par_ita eq 'accentrat/ore__adj'
		|| $par_ita eq 'cafon/e__adj'
		|| $par_ita eq 'ampi/o__adj'
		|| $par_ita eq 'difen/sore__adj'
		|| $par_ita eq 'oppr/essore__adj'
		|| $par_ita eq 'belg/a__adj'
		|| $par_ita eq 'tedesc/o__adj')
		&& ($par_srd eq 'frantzes/u__adj'
		|| $par_srd eq 'linguìsti/cu__adj'
		|| $par_srd eq 'banduler/i__adj'
		|| $par_srd eq 'cunservador/e__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'tecnic/o__adj'	# amb sup
		|| $par_ita eq 'abbandonat/o__adj'
		|| $par_ita eq 'miser/o__adj'
		|| $par_ita eq 'integ/ro__adj'
		|| $par_ita eq 'caric/o__adj')
		&& ($par_srd eq 'frantzes/u__adj'
		|| $par_srd eq 'linguìsti/cu__adj'
		|| $par_srd eq 'banduler/i__adj'
		|| $par_srd eq 'cunservador/e__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_GDsup\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'cosiddett/o__adj'	# sense sup
		|| $par_ita eq 'suicid/a__adj'
		|| $par_ita eq 'acconc/io__adj'
		|| $par_ita eq 'accentrat/ore__adj'
		|| $par_ita eq 'cafon/e__adj'
		|| $par_ita eq 'ampi/o__adj'
		|| $par_ita eq 'difen/sore__adj'
		|| $par_ita eq 'oppr/essore__adj'
		|| $par_ita eq 'belg/a__adj'
		|| $par_ita eq 'tedesc/o__adj')
		&& ($par_srd eq 'meda__adj' || $par_srd eq 'fàtzil/e__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'tecnic/o__adj'	# amb sup
		|| $par_ita eq 'abbandonat/o__adj'
		|| $par_ita eq 'miser/o__adj'
		|| $par_ita eq 'integ/ro__adj'
		|| $par_ita eq 'caric/o__adj')
		&& ($par_srd eq 'meda__adj' || $par_srd eq 'fàtzil/e__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mfsup\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'albanes/e__adj' || $par_ita eq 'abbacchia/nte__adj')
		&& ($par_srd eq 'frantzes/u__adj'
		|| $par_srd eq 'linguìsti/cu__adj'
		|| $par_srd eq 'banduler/i__adj'
		|| $par_srd eq 'cunservador/e__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'fin/e__adj'
		&& ($par_srd eq 'frantzes/u__adj'
		|| $par_srd eq 'linguìsti/cu__adj'
		|| $par_srd eq 'banduler/i__adj'
		|| $par_srd eq 'cunservador/e__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GDsup\"/></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'fin/e__adj'
		&& ($par_srd eq 'meda__adj' || $par_srd eq 'fàtzil/e__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_mfsup\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'albanes/e__adj' || $par_ita eq 'abbacchia/nte__adj')
		&& ($par_srd eq 'meda__adj' || $par_srd eq 'fàtzil/e__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'extra__adj') && ($par_srd eq 'matessi__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/><s n=\"mf\"/><s n=\"sp\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/><s n=\"sp\"/></r></p></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'albanes/e__adj' || $par_ita eq 'abbacchia/nte__adj')
		&& ($par_srd eq 'matessi__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_srd, $stem_ita;
	} elsif ($par_ita eq 'fin/e__adj'
		&& ($par_srd eq 'matessi__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'cosiddett/o__adj'	# sense sup
		|| $par_ita eq 'suicid/a__adj'
		|| $par_ita eq 'acconc/io__adj'
		|| $par_ita eq 'accentrat/ore__adj'
		|| $par_ita eq 'cafon/e__adj'
		|| $par_ita eq 'ampi/o__adj'
		|| $par_ita eq 'difen/sore__adj'
		|| $par_ita eq 'oppr/essore__adj'
		|| $par_ita eq 'belg/a__adj'
		|| $par_ita eq 'tedesc/o__adj')
		&& ($par_srd eq 'matessi__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/><par n=\"sp_ND\"/></e>\n", $stem_srd, $stem_ita;
	} elsif (($par_ita eq 'tecnic/o__adj'	# amb sup
		|| $par_ita eq 'abbandonat/o__adj'
		|| $par_ita eq 'miser/o__adj'
		|| $par_ita eq 'integ/ro__adj'
		|| $par_ita eq 'caric/o__adj')
		&& ($par_srd eq 'matessi__adj')) {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/><par n=\"sp_ND\"/></e>\n", $stem_srd, $stem_ita;
	} else {
		print STDERR "No hi ha regla per a escriure_bidix_adj: par_ita = $par_ita ($lemma_ita) par_srd = $par_srd ($lemma_srd)\n";
#print STDERR "dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	}
}

sub escriure_bidix {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor) = @_;
	$lr_rl = " $lr_rl" if $lr_rl;
	my $a = " a=\"$autor\"" if $autor;
	if ($lr_rl eq ' i="yes"') {
		# no escric la línia 'i=yes' si ya és en el diccionari
print "entrada_ita_srd_yes{$morf_ita}{$lemma_ita}{$lemma_srd} = $entrada_ita_srd_yes{$morf_ita}{$lemma_ita}{$lemma_srd}\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
		return if $entrada_ita_srd_yes{$morf_ita}{$lemma_ita}{$lemma_srd};
	}
	if ($morf_srd eq 'vblex' && $morf_ita eq 'vblex') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_srd, $morf_srd, $stem_ita, $morf_ita;
	} elsif ($morf_srd eq 'adv' && $morf_ita eq 'adv') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_srd, $morf_srd, $stem_ita, $morf_ita;
	} elsif ($morf_srd eq 'cnjadv' && $morf_ita eq 'cnjadv') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_srd, $morf_srd, $stem_ita, $morf_ita;
	} elsif ($morf_srd eq 'pr' && $morf_ita eq 'pr') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_srd, $morf_srd, $stem_ita, $morf_ita;
	} elsif ($morf_srd eq 'pref' && $morf_ita eq 'pref') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_srd, $morf_srd, $stem_ita, $morf_ita;
	} elsif ($morf_srd eq 'ij' && $morf_ita eq 'ij') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_srd, $morf_srd, $stem_ita, $morf_ita;
	} elsif ($morf_srd eq 'n' && $morf_ita eq 'n') {
		escriure_bidix_n ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor);
	} elsif ($morf_srd eq 'adj' && $morf_ita eq 'adj') {
		escriure_bidix_adj ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor);
	} elsif ($morf_srd eq 'top' && $morf_ita eq 'top') {
		escriure_bidix_top ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor);
	} elsif ($morf_srd eq 'ant' && $morf_ita eq 'ant') {
		escriure_bidix_ant ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor);
	} elsif ($morf_srd eq 'org' && $morf_ita eq 'org') {
		escriure_bidix_org ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor);
	} elsif ($morf_srd eq 'al' && $morf_ita eq 'al') {
		escriure_bidix_al ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor);
	} elsif ($morf_srd eq 'acr' && $morf_ita eq 'acr') {
		escriure_bidix_acr ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor);
	} else {
		print STDERR "No hi ha regla per a escriure_bidix($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $lr_rl, $autor)\n";
	}
}

sub lema_srd_existeix_o_es_pot_crear {
	my ($lemma_srd, $morf_srd, $lemma_ita, $morf_ita, $autor) = @_;
#print "0. lema_srd_existeix_o_es_pot_crear($lemma_srd, $morf_srd, $autor)\n";
print "0. lema_srd_existeix_o_es_pot_crear: dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n"
	if $MOT && ($lemma_srd =~ /$MOT/o);
#print STDERR "lema_srd_existeix_o_es_pot_crear: dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n";
	return 1 if $dix_srd{$morf_srd}{$lemma_srd};

	# no existeix
	if ($morf_srd eq 'nxxxx') {
		# busco si està amb majúscula inicial
		if ($lemma_srd =~ m|^[a-zâéèêô]|o) {
			my $l_srd = $lemma_srd;
			substr($l_srd, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
			return 1 if $dix_srd{$morf_srd}{$l_srd};
		}
	}

	# potser es pot crear si és un verb amb <g> i tenim la capçalera
	return 0 if $lemma_srd =~ /^se /o;
	return 0 if $lemma_srd =~ /^s'/o;
print "3. lema_srd_existeix_o_es_pot_crear: dix_srd{$morf_srd}{$lemma_srd} = $dix_srd{$morf_srd}{$lemma_srd}\n"
	if $MOT && ($lemma_srd =~ /$MOT/o);
	if ($lemma_srd =~ /#/o) {
		return ! crear_g_srd($lemma_srd, $morf_srd, $autor);
	} else {
		my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
		my $stem_srd = $lemma_srd;
		$stem_srd =~ s| |<b/>|og;
#		$autor = "gianfranco" unless $autor;
		my $a = " a=\"$autor\"" if $autor;
		if ($morf_srd eq 'adv') {
			printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, 'bene__adv';
			$dix_srd{$morf_srd}{$lemma_srd} = 1;
			return 1;
		} elsif ($morf_srd eq 'al') {
			if ($par_ita eq 'ABC__np') {
				my $par_srd = 'Linux__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'Polizia__np') {
				my $par_srd = 'Wikipedia__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'Giochi_olimpici__np') {
				my $par_srd = 'Queen__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			}
			return 0;
		} elsif ($morf_srd eq 'org') {
			if ($par_ita eq 'Milan__np') {
				my $par_srd = 'Milan__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'Fiat__np') {
				my $par_srd = 'Fiat__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'Brigate_Rosse__np') {
				my $par_srd = 'Natziones_Unides__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			}
			return 0;
		} elsif ($morf_srd eq 'top') {
#			if ($lemma_ita =~ m|^Santu|o || $lemma_ita =~ m|^Santo|o || $lemma_ita =~ m|^San |o) {
#			}
			if ($par_ita eq 'Afghanistan__np') {
				my $par_srd = 'Afganistàn__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'Europa__np') {
				my $par_srd = 'Etiòpia__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'USA__np') {
				my $par_srd = 'Istados_Unidos__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'Maldive__np') {
				my $par_srd = 'Is_Pratzas__np';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			}
			return 0;
		} elsif ($morf_srd eq 'acr') {
			if ($par_ita eq 'BBVA__n') {
				my $par_srd = 'PNB__n';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'TV__n') {
				my $par_srd = 'TV__n';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			} elsif ($par_ita eq 'PIL__n') {
				my $par_srd = 'kg__n';
				printf $fsrd "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				$dix_srd{$morf_srd}{$lemma_srd} = $par_srd;
				return 1;
			}
			return 0;
		} elsif ($morf_srd eq 'vblex') {
			return escriure_srd_vblex($lemma_srd, $a);
		} elsif ($morf_srd eq 'adj') {
			return escriure_srd_adj($lemma_srd, $a);
		} elsif ($morf_srd eq 'n') {
			return escriure_srd_n($lemma_srd, $par_ita, $a);
		}
		return 0;
	}
print "lema $lemma_srd, morf_srd $morf_srd no existeix\n";
	return 0;
}

sub escriure_top_ita {
	my ($lemma_ita, $lemma_srd) = @_;
	my $a = " a=\"commune\"";

	my $stem_ita = $lemma_ita;
	$stem_ita =~ s| |<b/>|og;
	if ($lemma_ita =~ m|^Sainte|o) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Bulgarie__np';
		return 'Bulgarie__np';
	} elsif ($lemma_ita =~ m|^Saint|o) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Iran__np';
		return 'Iran__np';
	} elsif ($lemma_ita =~ m|^la |oi) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Bulgarie__np';
		return 'Bulgarie__np';
	} elsif ($lemma_ita =~ m|^le |oi) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Iran__np';
		return 'Iran__np';
	} elsif ($lemma_srd =~ m|^la |oi) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Bulgarie__np';
		return 'Bulgarie__np';
	} elsif ($lemma_srd =~ m|^los |oi) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Iran__np';
		return 'Iran__np';
	} elsif ($lemma_srd =~ m|^les |oi) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Bulgarie__np';
		return 'Bulgarie__np';
	} elsif ($lemma_ita !~ m|[aes]$|o) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Iran__np';
		return 'Iran__np';
	} elsif ($lemma_ita =~ m|[^e]s$|o) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Iran__np';
		return 'Iran__np';
	} elsif ($lemma_ita =~ m|a$|oi) {
		printf $fita "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Bulgarie__np';
		return 'Bulgarie__np';
	} else {
		return 0;
	}
}

sub escriure_vblex_ita {
	my ($lemma_ita) = @_;
	my $a = " a=\"automatique\"";

	if ($lemma_ita =~ /ger$/o) {
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'allong/er__vblex';
		return 1;
	} elsif ($lemma_ita =~ /ayer$/o) {
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/yer$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'bala/yer__vblex';
		return 1;
	} elsif ($lemma_ita =~ /oyer$/o) {
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/yer$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'côto/yer__vblex';
		return 1;
	} elsif ($lemma_ita =~ /cer$/o) {
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/cer$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'annon/cer__vblex';
		return 1;
	} elsif ($lemma_ita =~ /e(.)er$/o) {
		my $cons = $1;
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/e.er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'ach/e[T]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /é(.)er$/o) {
		my $cons = $1;
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/é.er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'accél/é[R]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /echer$/o) {
		my $cons = 'ch';
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/e..er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'ach/e[T]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /écher$/o) {
		my $cons = 'ch';
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/é..er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'accél/é[R]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /équer$/o) {
		#<e lm="hypothéquer"><i>hypoth</i><par n="accél/é[R]er__vblex" prm="qu"/></e>
		my $cons = 'qu';
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/e..er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'ach/e[T]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /éguer$/o) {
		my $cons = 'gu';
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/e..er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'ach/e[T]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /equer$/o) {
		my $cons = 'qu';
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/e..er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'ach/e[T]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /equer$/o) {
		my $cons = 'qu';
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/e..er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'ach/e[T]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /écrer$/o) {
		my $cons = 'cr';
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/é..er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'accél/é[R]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /étrer$/o) {
		my $cons = 'tr';
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/é..er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'accél/é[R]er__vblex', $cons;
		return 1;
	} elsif ($lemma_ita =~ /[aiouyâêîôûï][bcdfghjklmnpqrstvwxz][bcdfghjklmnpqrstvwxz]*[i]*er$/o
		|| $lemma_ita =~ /[aiouyâêîôûï][gq]uer$/o
		|| $lemma_ita =~ /ouer$/o
		|| $lemma_ita =~ /[éiu]er$/o
		|| $lemma_ita =~ /er[lns]er$/o
		|| $lemma_ita =~ /eller$/o
		|| $lemma_ita =~ /effer$/o
		|| $lemma_ita =~ /errer$/o
		|| $lemma_ita =~ /enfler$/o
		|| $lemma_ita =~ /estrer$/o
		|| $lemma_ita =~ /e[cn]ter$/o
		|| $lemma_ita =~ /n[gq]uer$/o
		) {
		my $stem_ita = $lemma_ita;
		$stem_ita =~ s/er$//o;
		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'abaiss/er__vblex';
		return 1;
# No es pot posar "ir" automàticament perquè no sabem si és incoatiu (salir) o no (dormir)
#	} elsif ($lemma_ita =~ /ir$/o) {
#		my $stem_ita = $lemma_ita;
#		$stem_ita =~ s/er$//o;
#		printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'about/[]ir__vblex';
#		return 1;
	} else {
		return 0;
	}
}

sub lema_ita_existeix_o_es_pot_crear {
	my ($lemma_ita, $morf_ita, $autor, $lemma_srd) = @_;
#print "0. lema_ita_existeix_o_es_pot_crear($lemma_ita, $morf_ita, $autor)\n";
print "0. lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n"
	if $MOT && ($lemma_ita =~ /$MOT/oi);
#print STDERR "lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	return 1 if $dix_ita{$morf_ita}{$lemma_ita};
#print "lema $lemma_ita, morf_ita $morf_ita no existeix\n";

	if ($morf_ita eq 'top' && $lemma_ita =~ / \-\-Italie, Suisse$/o) {
		my $lemma = $lemma_ita;
		$lemma =~ s/ \-\-Italie, Suisse$//o;
print "1. lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma} = $dix_ita{$morf_ita}{$lemma}\n"
	if $MOT && ($lemma_ita =~ /$MOT/oi);
		return 1 if $dix_ita{$morf_ita}{$lemma};
	}

	# no existeix
	if ($morf_ita eq 'n') {
		# busco si està amb majúscula inicial
		if ($lemma_ita =~ m|^[a-zâéèêô]|o) {
			my $l_ita = $lemma_ita;
			substr($l_ita, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
			return 0 if $dix_ita{$morf_ita}{$l_ita};	# Dic que no es pot crear, però perquè es farà després i altrament es pot agafar la paraula en minúscula del fitxer de n'Ortolà
		}
	}

	return 0 unless $GEN_ITA;
	# potser es pot crear si és un verb amb <g> i tenim la capçalera
	return 0 if $lemma_ita =~ /^se /o;
	return 0 if $lemma_ita =~ /^s'/o;

	if ($morf_ita eq 'adj') {
		my $tmp = $dix_itaadj_def{$morf_ita}{$lemma_ita};
		if ($tmp) {
			$tmp =~ s/><i/ a="jaumeortola"><i/o if $tmp !~ / a="jaumeortola"/o;
			print $fita $tmp, "\n";
			$dix_ita{$morf_ita}{$lemma_ita} = $dix_itaadj{$morf_ita}{$lemma_ita};
			$dix_ita{$morf_ita}{$lemma_ita} = 1;
			return 1;
		} else {
			return 0;
		}
	} elsif ($morf_ita eq 'adv') {
		my $tmp = $dix_itaadv_def{$morf_ita}{$lemma_ita};
		if ($tmp) {
#			$tmp =~ s/><i/ a="jaumeortola"><i/o;
			$tmp =~ s/comment__adv/hier__adv/o;
			print $fita $tmp, "\n";
			$dix_ita{$morf_ita}{$lemma_ita} = $dix_itaadv{$morf_ita}{$lemma_ita};
			$dix_ita{$morf_ita}{$lemma_ita} = 1;
			return 1;
		} else {
			print STDERR "Genero l'adv ita $lemma_ita tot i que no trobat al diccionari de n'Ortolà\n";
			my $stem_ita = $lemma_ita;
			$stem_ita =~ s| |<b/>|og;
			$autor = "gianfranco" unless $autor;
			my $a = " a=\"$autor\"" if $autor;
			printf $fita "<e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'hier__adv';
			$dix_ita{$morf_ita}{$lemma_ita} = 1;
			return 1;
		}
	} elsif ($morf_ita eq 'n') {
		my $tmp = $dix_itan_def{$morf_ita}{$lemma_ita};
		if ($tmp) {
			$tmp =~ s/><i/ a="jaumeortola"><i/o if $tmp !~ / a="jaumeortola"/o;
			print $fita $tmp, "\n";
			$dix_ita{$morf_ita}{$lemma_ita} = $dix_itan{$morf_ita}{$lemma_ita};
			$dix_ita{$morf_ita}{$lemma_ita} = 1;
			return 1;
		} else {
			return 0;
		}
	} elsif ($morf_ita eq 'vblex') {
		if ($dix_itav{vblex}{$lemma_ita}) { # de moment, verificació ortogràfica i prou
			if (escriure_vblex_ita($lemma_ita)) {
				$dix_ita{$morf_ita}{$lemma_ita} = 1;
				return 1;
			} else {
				print STDERR "Warning: verb $lemma_ita és en dicollecte, però no el puc generar\n";
			}
			return 0;
		} else {
			print STDERR "Error ortogràfic: verb $lemma_ita no és en dicollecte\n";
			return 0;
		}
	} elsif ($morf_ita eq 'top') {
print "3. lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n"
	if $MOT && ($lemma_ita =~ /$MOT/oi);
		return 0;
	}
	return 0;
}

sub lema_ita_existeix_o_es_pot_crear {
	my ($lemma_ita, $morf_ita, $autor, $lemma_srd) = @_;
#print "0. lema_ita_existeix_o_es_pot_crear($lemma_ita, $morf_ita, $autor)\n";
print "0. lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n"
	if $MOT && ($lemma_ita =~ /$MOT/oi);
#print STDERR "lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n";
	return 1 if $dix_ita{$morf_ita}{$lemma_ita};
#print "lema $lemma_ita, morf_ita $morf_ita no existeix\n";

	if ($morf_ita eq 'top' && $lemma_ita =~ / \-\-Italie, Suisse$/o) {
		my $lemma = $lemma_ita;
		$lemma =~ s/ \-\-Italie, Suisse$//o;
print "1. lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma} = $dix_ita{$morf_ita}{$lemma}\n"
	if $MOT && ($lemma_ita =~ /$MOT/oi);
		return 1 if $dix_ita{$morf_ita}{$lemma};
	}

	# no existeix
	if ($morf_ita eq 'n') {
		# busco si està amb majúscula inicial
		if ($lemma_ita =~ m|^[a-zâéèêô]|o) {
			my $l_ita = $lemma_ita;
			substr($l_ita, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
			return 0 if $dix_ita{$morf_ita}{$l_ita};	# Dic que no es pot crear, però perquè es farà després i altrament es pot agafar la paraula en minúscula del fitxer de n'Ortolà
		}
	}

	return 0 unless $GEN_ITA;
	# potser es pot crear si és un verb amb <g> i tenim la capçalera
	return 0 if $lemma_ita =~ /^se /o;
	return 0 if $lemma_ita =~ /^s'/o;

print "3. lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n"
	if $MOT && ($lemma_ita =~ /$MOT/o);
	if ($lemma_ita =~ /#/o) {
		return ! crear_g($lemma_ita, $morf_ita);
	} else {
print "4. lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n"
	if $MOT && ($lemma_ita =~ /$MOT/o);
		if ($morf_ita eq 'vblex') {
print "5. lema_ita_existeix_o_es_pot_crear: dix_ita{$morf_ita}{$lemma_ita} = $dix_ita{$morf_ita}{$lemma_ita}\n"
	if $MOT && ($lemma_ita =~ /$MOT/o);
			if ($dix_itav{vblex}{$lemma_ita}) {
				return escriure_mono_vblex($lemma_ita);
			} else {
				print STDERR "Error ortogràfic: verb $lemma_ita no és en la llista de verbs\n";
				return 0;
			}
		} elsif ($morf_ita eq 'adv') {
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s| |<b/>|og;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'ieri__adv';
				return 1;
		} elsif ($morf_ita eq 'cog') {
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s| |<b/>|og;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'Saussure__np';
				return 1;
		} elsif ($morf_ita eq 'adj') {
			my $tmp = $dix_itaadj_def{$morf_ita}{$lemma_ita};
			if ($tmp) {
				$tmp =~ s/><i/ a="jaumeortola"><i/o if $tmp !~ /a="jaumeortola"/;
				print $fita $tmp, "\n";
				$dix_ita{$morf_ita}{$lemma_ita} = $dix_itaadj{$morf_ita}{$lemma_ita};
				return 1;
			} elsif ($lemma_ita =~ / /o) {
				return 0;
			} elsif ($lemma_ita =~ /ista$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/a$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'suicid/a__adj';
				$dix_ita{$morf_ita}{$lemma_ita} = 'suicid/a__adj';
				return 1;
			} elsif ($lemma_ita =~ /ico$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/o$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'tecnic/o__adj';
				$dix_ita{$morf_ita}{$lemma_ita} = 'tecnic/o__adj';
				return 1;
			} elsif ($lemma_ita =~ /io$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/o$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'ampi/o__adj';
				$dix_ita{$morf_ita}{$lemma_ita} = 'ampi/o__adj';
				return 1;
			} elsif ($lemma_ita =~ /o$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/o$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'cosiddett/o__adj';
				$dix_ita{$morf_ita}{$lemma_ita} = 'cosiddett/o__adj';
				return 1;
			} elsif ($lemma_ita =~ /tore$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/ore$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'accentrat/ore__adj';
				$dix_ita{$morf_ita}{$lemma_ita} = 'accentrat/ore__adj';
				return 1;
			} elsif ($lemma_ita =~ /e$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/e$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'albanes/e__adj';
				$dix_ita{$morf_ita}{$lemma_ita} = 'albanes/e__adj';
				return 1;
#			} elsif ($lemma_ita =~ /a$/o) {
#				my $a = " a=\"automatico\"";
#				my $stem_ita = $lemma_ita;
#				$stem_ita =~ s/a$//o;
#				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'suicid/a__adj';
#				$dix_ita{$morf_ita}{$lemma_ita} = 'suicid/a__adj';
#				return 1;
			} else {
				return 0;
			}
		} elsif ($morf_ita eq 'n') {
			my $tmp = $dix_itan_def{$morf_ita}{$lemma_ita};
			if ($tmp) {
				$tmp =~ s/><i/ a="jaumeortola"><i/o if $tmp !~ /a="jaumeortola"/;
				print $fita $tmp, "\n";
				$dix_ita{$morf_ita}{$lemma_ita} = $dix_itan{$morf_ita}{$lemma_ita};
				return 1;
			} elsif ($lemma_ita =~ / /o) {
				return 0;
			} elsif ($lemma_ita =~ /io$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/o$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'abbagli/o__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'abbagli/o__n';
				return 1;
			} elsif ($lemma_ita =~ /ista$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/a$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'suicid/a__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'suicid/a__n';
				return 1;
			} elsif ($lemma_ita =~ /[cg]a$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/a$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'tasc/a__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'tasc/a__n';
				return 1;
			} elsif ($lemma_ita =~ /cia$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/ia$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'alzatacc/ia__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'alzatacc/ia__n';
				return 1;
			} elsif ($lemma_ita =~ /a$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/a$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'cas/a__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'cas/a__n';
				return 1;
			} elsif ($lemma_ita =~ /zione$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/e$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'abbreviazion/e__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'abbreviazion/e__n';
				return 1;
			} elsif ($lemma_ita =~ /tà$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'abilità__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'abilità__n';
				return 1;
			} elsif ($lemma_ita =~ /mento$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/o$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'abbain/o__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'abbain/o__n';
				return 1;
			} elsif ($lemma_ita =~ /tore$/o) {
				my $a = " a=\"automatico\"";
				my $stem_ita = $lemma_ita;
				$stem_ita =~ s/ore$//o;
				printf $fita "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_ita, $stem_ita, 'agricolt/ore__n';
				$dix_ita{$morf_ita}{$lemma_ita} = 'agricolt/ore__n';
				return 1;
			} else {
				return 0;
			}
		}
		return 0;
	}
}

# aquesta funció fa el tractament d'una parella neta (1 lema srd - 1 lema ita), introduint el que calgui en els diccionaris
# si $primer == 0, cal afegir una restricció RL
sub tractar_parella {
	my ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $autor, $primer, $n_linia) = @_;

#print "tractar_parella ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $autor, $primer)\n";
print "1. tractar_parella ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $autor, $primer)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
#print "1b. tractar_parella ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $autor, $primer)\n";
#print "5. ita dix_ita{$MORF_TRACT}{$MOT} = $dix_ita{$MORF_TRACT}{$MOT}\n";

	if (!lema_ita_existeix_o_es_pot_crear ($lemma_ita, $morf_ita, $autor, $lemma_srd)) {
		# tractament maj/min
		if ($morf_ita eq 'n') {
print "Ini minúscules/majúscules 1: lemma_ita = $lemma_ita, lemma_srd = $lemma_srd\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
			if ($lemma_ita =~ m|^[A-ZÂÉÈÊÎÔ]|o) {
				my $l_ita = $lemma_ita;
				$lemma_ita =~ tr|[A-ZÂÉÈÊÎÔ]|[a-zâéèêîô]|;
				$stem_ita =~ tr|[A-ZÂÉÈÊÎÔ]|[a-zâéèêîô]|;
				my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
				if ($par_ita) {
					$lemma_srd =~ tr|[A-ZÂÉÈÊÎÔ]|[a-zâéèêîô]|;
					$stem_srd =~ tr|[A-ZÂÉÈÊÎÔ]|[a-zâéèêîô]|;
#print "Canvi a minúscules: lemma_ita = $lemma_ita, lemma_srd = $lemma_srd\n";
				} else {
					print STDERR "1. Falta ita $l_ita <$morf_ita>, l. $n_linia\n";
					return 0;
				}
			} else {
				my $l_ita = $lemma_ita;
				substr($lemma_ita, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
				substr($stem_ita, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
				my $par_ita = $dix_ita{$morf_ita}{$lemma_ita};
				if ($par_ita) {
					substr($lemma_srd, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
					substr($stem_srd, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
print "Canvi a majúscules 1: lemma_ita = $lemma_ita, lemma_srd = $lemma_srd\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
				} else {
					print STDERR "2. Falta ita $l_ita <$morf_ita>, l. $n_linia\n";
					return 0;
				}
			}
		} else {
			print STDERR "3. Falta ita $lemma_ita <$morf_ita>, l. $n_linia\n";
			return 0;
		}
	}
	if (!lema_srd_existeix_o_es_pot_crear ($lemma_srd, $morf_srd, $lemma_ita, $morf_ita, $autor)) {
		# tractament maj/min
		if ($morf_srd eq 'n') {
print "Ini minúscules/majúscules 2: lemma_ita = $lemma_ita, lemma_srd = $lemma_srd\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
			if ($lemma_srd =~ m|^[A-ZÂÉÈÊÎÔ]|o) {
				my $l_srd = $lemma_srd;
				$lemma_srd =~ tr|[A-ZÂÉÈÊÎÔ]|[a-zâéèêîô]|;
				$stem_srd =~ tr|[A-ZÂÉÈÊÎÔ]|[a-zâéèêîô]|;
				my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
				if ($par_srd) {
#print "Canvi a minúscules: lemma_ita = $lemma_ita, lemma_srd = $lemma_srd\n";
				} else {
					print STDERR "1. Falta srd $l_srd <$morf_srd>, l. $n_linia\n";
					return 0;
				}
			} else {
				my $l_srd = $lemma_srd;
				substr($lemma_srd, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
				substr($stem_srd, 0, 1) =~ tr|[a-zâéèêîô]|[A-ZÂÉÈÊÎÔ]|;
				my $par_srd = $dix_srd{$morf_srd}{$lemma_srd};
				if ($par_srd) {
print "Canvi a majúscules 2: lemma_ita = $lemma_ita, lemma_srd = $lemma_srd\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
				} else {
					print STDERR "2. Falta srd $l_srd <$morf_srd>, l. $n_linia\n";
					return 0;
				}
			}
		} else {
			print STDERR "3. Falta srd $lemma_srd <$morf_srd>, l. $n_linia\n";
			return 0;
		}
	}

	# A partir d'aquí, partim de la base que els dos lemes existeixen en els monodixs

	if (exists $dix_ita_srd{$morf_ita}{$lemma_ita}) {
		# ja existeix una traducció per al lema ita
print "1.0.\n" if $MOT && ($lemma_srd =~ /$MOT/o || $lemma_ita =~ /$MOT/o);
		if (is_in($dix_ita_srd{$morf_ita}{$lemma_ita}, $lemma_srd)) {
			# ja existeix aquesta traducció per al lema ita
			# no fem res
			return;
		} else {
			# no existeix encara aquesta traducció per al lema ita
			if (exists $dix_srd_ita{$morf_srd}{$lemma_srd}) {
				# ja existeix una traducció per al lema srd
				if (is_in($dix_srd_ita{$morf_srd}{$lemma_srd}, $lemma_ita)) {
					# ja existeix aquesta traducció per al lema srd
					# no fem res
					return;
				} else {
					# introduïm la parella perquè en quedi constància (algun dia es pot activar), però fem que s'ignori
print "1. escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, 'i=\"yes\"', $autor)\n" if $MOT && ($lemma_srd =~ /$MOT/o || $lemma_ita =~ /$MOT/o);
#print STDERR "1. escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, 'i=\"yes\"', $autor)\n" if $lemma_ita eq 'rifle';
					escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, 'i="yes"', $autor);
					return;
				}
			} else {
				# no existeix encara una traducció per al lema srd
				# recordatori: ja existeix una traducció per al lema ita
				# traducció en la direcció srd > ita
				# $primer no afecta aquí perquè suma RL a RL: queda igual
				my $direccio = 'r="LR"';
print "2. escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $direccio, $autor)\n" if $MOT && ($lemma_srd =~ /$MOT/o || $lemma_ita =~ /$MOT/o);
				escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $direccio, $autor);
			}
		}

	} else {
		# no existeix una traducció per al lema ita
print "3.0.: not exists dix_ita_srd{$morf_ita}{$lemma_ita}\n" if $MOT && ($lemma_srd =~ /$MOT/o || $lemma_ita =~ /$MOT/o);
		if (exists $dix_srd_ita{$morf_srd}{$lemma_srd}) {
			# ja existeix una traducció per al lema srd
			if (is_in($dix_srd_ita{$morf_srd}{$lemma_srd}, $lemma_ita)) {
				# ja existeix aquesta traducció per al lema srd
				# no fem res
				return;
			} else {
				# $primer no afecta aquí perquè suma LR a LR: queda igual
				my $direccio = ($primer) ? 'r="RL"' : 'i="yes"';
print "3. escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $direccio, $autor)\n" if $MOT && ($lemma_srd =~ /$MOT/o || $lemma_ita =~ /$MOT/o);
				escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $direccio, $autor);
				return;
			}
		} else {
print "4.0.\n" if $MOT && ($lemma_srd =~ /$MOT/o || $lemma_ita =~ /$MOT/o);
#print STDERR "4. escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, '', $autor)\n" if $lemma_ita eq 'rifle';
			my $direccio = ($primer) ? '' : 'r="LR"';
			escriure_bidix ($lemma_srd, $stem_srd, $morf_srd, $lemma_ita, $stem_ita, $morf_ita, $direccio, $autor);
			return;
		}
	}
}

# llegeixo el fitxer d'entrada i en poso la informació a %entrada_ita_srd i %entrada_srd_ita
sub llegir_entrada {
#print "llegir_entrada\n";
my %carregat_ita_srd = ();
my $i = 0;
<STDIN>;	# saltem la primera línia
my ($stem_srd, $stem_ita, $en_srd, $gen_ita, $num_srd, $num_ita, $lemma_srd, $lemma_ita, $lemma_srd_ini, $lemma_ita_ini);
while (my $linia = <STDIN>) {
#print "1. l. $.: $linia\n";
print "x00. $linia\n" if $MOT && ($linia =~ /$MOT/oi);
	next if $linia =~ /xxx/io;

	if ($POSAR_MIN_INI
		&& $MORF_TRACT ne 'top'
		&& $MORF_TRACT ne 'ant'
		&& $MORF_TRACT ne 'org'
		&& $MORF_TRACT ne 'al'
		&& $MORF_TRACT ne 'acr') {
		substr ($linia, 0, 1) =~ tr|A-ZÂÉÈÊÎÔ|a-zâéèêîô|;
	}

#	next if $linia !~ /\t$MORF_TRACT\t/o;
#print "2. l. $.: $linia\n";
	next if $linia =~ /---/o;
#print "3. l. $.: $linia\n";
print "x03. $linia\n" if $MOT && ($linia =~ /$MOT/oi);
	chop $linia;

	$linia =~ s/’/'/og;

	my @dades = split /\t/, $linia;
	$linia = join ("\t", $dades[0], $dades[1], $dades[2], $dades[3], $dades[4]);
	if ($linia =~ /\(/o) {
		print STDERR "Error fitxer entrada en l. $. (parèntesi): $linia\n";
		next;
	}
#print "4. l. $.: $linia\n";

	$linia =~ s/[^a-zàâèéûíîòóôúùûœçA-ZÀÂÈÉÊÍÎÒÓÔÚÙÛÇ·'\t]+$//o unless $MORF_TRACT eq 'acr' || $MORF_TRACT eq 'org' || $MORF_TRACT eq 'al'; 
	$linia =~ s|\r| |og;
	$linia =~ s|#a\t|\t|og;
	$linia =~ s|#|# |og;	# per evitar errors com "faire#pression sur"
	$linia =~ s|' |'|og;	# coup d' État
	$linia =~ s| +| |og;
	$linia =~ s|’|'|og;

	# arreglem majúscules
	# passo tot a minúscules, excepte si hi ha noms propis o acrònims
	if ($linia !~ /\ttop\t/o && $linia !~ /\tant\t/o && $linia !~ /\tal\t/o && $linia !~ /\tacr\t/o) {
		$dades[0] =~ tr/[A-ZÀÈÉíÒÓÚÇ]/[a-zàèéíòóúç/;
		$dades[2] =~ tr/[A-ZÀÈÉíÒÓÚÇ]/[a-zàèéíòóúç/;
	}

	my @dades = split /\t/, $linia;
	for (my $i=0; $i<=$#dades; $i++) { 
		$dades[$i] =~ s/^ +//o;
		$dades[$i] =~ s/ +$//o;
	}

#print "x01. $linia\n" if $MOT && ($lemma_srd eq $MOT || $lemma_ita eq $MOT);
	next unless $dades[2];			# línia buida
	next if $dades[5] =~ /\?/o;		# dubtes
	next if length $dades[0] == 1;		# una sola lletra
#print "99. $. dades[0] = $dades[0]\n" if length $dades[0] == 1;	# una sola lletra
#print "x04. $linia\n" if $MOT && ($lemma_srd eq $MOT || $lemma_ita eq $MOT);

	$stem_ita = $dades[0];
	$stem_ita =~ s| +| |og;
	$stem_ita =~ s|^ ||o;
	$stem_ita =~ s| $||o;
	$stem_ita =~ s|#$||o;
	$lemma_ita_ini = $lemma_ita = $stem_ita;
	if ($stem_ita =~ m/\#/o) {
		$stem_ita = $` . '<g>' . $' . '</g>';
	}
	$stem_ita =~ s| |<b/>|og;

	my $gram_ita = $dades[1];
	$gram_ita =~ s/^<//og;
	$gram_ita =~ s/>$//og;
	$gram_ita =~ s/^ *//og;
	$gram_ita =~ s/ *$//og;
	$gram_ita =~ s/><//og;
	$gram_ita = $MORF_TRACT if $gram_ita eq 'nadj' && $MORF_TRACT eq 'n';
	$gram_ita = $MORF_TRACT if $gram_ita eq 'nadj' && $MORF_TRACT eq 'adj';
#print "x05. gram_ita = $gram_ita\n" if $MOT && ($lemma_srd eq $MOT || $lemma_ita eq $MOT);
	next if $gram_ita ne $MORF_TRACT;

	$dades[2] =~ s|,|;|og;
	$dades[2] =~ s|:|;|og;

	my $autor = $dades[4];
	$autor =~ s| +| |og;
	$autor =~ s|^ ||o;
	$autor =~ s| $||o;
#$autor = 'gianfranco' unless $autor;
#print "5. l. $.: $linia\n";
print "x05. $linia\n" if $MOT && ($lemma_srd eq $MOT || $lemma_ita eq $MOT);
print "autor = $autor\n" if $MOT && ($lemma_srd eq $MOT || $lemma_ita eq $MOT);

print "11. $linia - stem_ita=$stem_ita, lemma_ita=$lemma_ita, gram_ita = $gram_ita, dades[2]=$dades[2]\n" if $MOT && ($lemma_srd =~ /$MOT/o || $lemma_ita eq $MOT);
	my @stem_srd = split /;/o, $dades[2];
	my $primer = 1;
	my $n = 0; 	# index en @stem_srd
	foreach my $stem_srd (@stem_srd) {
#print STDERR "stem_srd = #$stem_srd#\n";
		$stem_srd =~ s| +| |og;
		$stem_srd =~ s|^ ||o;
		$stem_srd =~ s| $||o;
		$stem_srd =~ s| $||o;	# no és un espai en blanc (no sé què és però apareix en el fitxer: ho posa l'Open Office davant de ; en ita)
		next unless $stem_srd;
#print STDERR "stem_srd = #$stem_srd#\n";
		$lemma_srd_ini = $lemma_srd = $stem_srd;
		if ($stem_srd =~ m/\#/o) {
			$stem_srd = $` . '<g>' . $' . '</g>';
#			$lemma_srd =~ s/#//o;
		}
print "x06. $linia\n" if $MOT && ($lemma_srd eq $MOT || $lemma_ita eq $MOT);
		$stem_srd =~ s| |<b/>|og;

		my $gram_ita = $dades[1];
		$gram_ita =~ s/^<//og;
		$gram_ita =~ s/>$//og;
		$gram_ita =~ s/^ *//og;
		$gram_ita =~ s/ *$//og;
		$gram_ita =~ s/><//og;
		$gram_ita = $MORF_TRACT if $gram_ita eq 'nadj' && $MORF_TRACT eq 'n';
		$gram_ita = $MORF_TRACT if $gram_ita eq 'nadj' && $MORF_TRACT eq 'adj';
print "x05. gram_ita = $gram_ita\n" if $MOT && ($lemma_srd eq $MOT || $lemma_ita eq $MOT);
		if ($gram_ita =~ /></o) {
			my @gram_ita = split /;/o, $gram_ita;
			$gram_ita = $gram_ita[$n];
			$gram_ita = $gram_ita[0] unless $gram_ita;	# potser hi ha només una definició per a totes les possibilitats
			$gram_ita = 'n' if $gram_ita =~ /^n>/o;
			$gram_ita = 'np' if $gram_ita =~ /^np>/o;
		}

		my $gram_srd = $gram_ita;
print "12. $linia - stem_srd=$stem_srd, lemma_srd=$lemma_srd, gram_srd = $gram_srd, gram_ita = $gram_ita\n" if $MOT && ($lemma_srd =~ /$MOT/o || $lemma_ita eq $MOT);
#print "12. $linia - stem_srd=$stem_srd, lemma_srd=$lemma_srd, gram_srd = $gram_srd, gram_ita = $gram_ita\n";

		# miro si la parella ja està carregada al diccionari
		# si ho està, no cal afegir-la per no bloquejar la càrrega de paraules si $CARREGA_UNICS == 1
		if (is_in($dix_ita_srd{$gram_ita}{$lemma_ita}, $lemma_srd)
			|| is_in($dix_srd_ita{$gram_srd}{$lemma_srd}, $lemma_ita)
			|| $entrada_ita_srd_yes{$gram_ita}{$lemma_ita}{$lemma_srd}) {
print "Skip 1 $lemma_ita - $lemma_srd\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
			next;
		}
		# miro si ja totes dues paraules ja tenen traducció en el diccionari
		# en aquest cas es generaria només i="yes", però mentrestant bloquejaria la càrrega d'altres paraules
		if ($dix_ita_srd{$gram_ita}{$lemma_ita} && $dix_srd_ita{$gram_srd}{$lemma_srd}) {
print "Skip 2 $lemma_ita - $lemma_srd\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
			next;
		}
		# miro si la parella j'ha a estat posada com a pendent de carregar (hi ha entrades repetides en diferents llocs de diccionari)
		if (exists $carregat_ita_srd{$gram_ita}{$lemma_ita}{$lemma_srd}) {
print "Skip 3 $lemma_ita - $lemma_srd\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
			next;
		}
		
		$data[$i]{line} = $.;
		$data[$i]{lemma_srd} = $lemma_srd;
		$data[$i]{stem_srd} = $stem_srd;
		$data[$i]{gram_srd} = $gram_srd;
		$data[$i]{lemma_ita} = $lemma_ita;
		$data[$i]{stem_ita} = $stem_ita;
		$data[$i]{gram_ita} = $gram_ita;
		$data[$i]{autor} = $autor;
		$data[$i]{primer} = $primer;
		push @{$entrada_ita_srd{$gram_ita}{$lemma_ita}}, $lemma_srd;
		push @{$entrada_srd_ita{$gram_srd}{$lemma_srd}}, $lemma_ita;
		$carregat_ita_srd{$gram_ita}{$lemma_ita}{$lemma_srd} = 1;		# hi ha entrades repetides: me l'apunto per a no repetir-la
print "carregat_ita_srd{$gram_ita}{$lemma_ita}{$lemma_srd} = $carregat_ita_srd{$gram_ita}{$lemma_ita}{$lemma_srd}\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
		$i++;
		$primer = 0;
	}
}
}

llegir_dix('ita', $fdixita, \%dix_ita, \%dix_ita_prm);
print "1. nfitx = ita dix_ita{$MORF_TRACT}{$MOT} = $dix_ita{$MORF_TRACT}{$MOT}\n" if $MOT;
llegir_dix('srd', $fdixsrd, \%dix_srd);
print "2. nfitx = srd dix_srd{$MORF_TRACT}{$MOT} = $dix_srd{$MORF_TRACT}{$MOT}\n" if $MOT;
llegir_dix_ortola('ita', $fdixitan, \%dix_itan, \%dix_itan_def) if $MORF_TRACT eq 'n';
print "3. nfitx = ita dix_itan{$MORF_TRACT}{$MOT} = $dix_itan{$MORF_TRACT}{$MOT}\n" if $MOT;
llegir_dix_ortola('ita', $fdixitaadj, \%dix_itaadj, \%dix_itaadj_def) if $MORF_TRACT eq 'adj';
print "3. nfitx = ita dix_itan{$MORF_TRACT}{$MOT} = $dix_itan{$MORF_TRACT}{$MOT}\n" if $MOT;
llegir_dix_ortola('ita', $fdixitaadv, \%dix_itaadv, \%dix_itaadv_def) if $MORF_TRACT eq 'adv';
print "4. nfitx = ita dix_itaadv{$MORF_TRACT}{$MOT} = $dix_itaadv{$MORF_TRACT}{$MOT}\n" if $MOT;
llegir_bidix($fdixbi, \%dix_ita_srd, \%dix_srd_ita, \%entrada_ita_srd_yes);
#print "5. dix_srd_ita{$MORF_TRACT}{$MOT}[0] = $dix_srd_ita{$MORF_TRACT}{$MOT}[0]\n"; COMPTE! No descomentar pqè crea l'entrada i crear pbs amb els exists posteriors
#print "5. dix_ita_srd{$MORF_TRACT}{$MOT}[0] = $dix_ita_srd{$MORF_TRACT}{$MOT}[0]\n"; # COMPTE! No descomentar pqè crea l'entrada i crear pbs amb els exists posteriors
#print "6. dix_ita_srd{$MORF_TRACT}{$MOT} = $dix_ita_srd{$MORF_TRACT}{$MOT}\n";

llegir_entrada ();

#my $gram_ita = 'vblex';
#my $lemma_ita = 'abaisser';
#print "#entrada_ita_srd{$gram_ita}{$lemma_ita} = $#{$entrada_ita_srd{$gram_ita}{$lemma_ita}}\n";
#my $gram_srd = 'vblex';
#my $lemma_srd = 'bèssiér';
#print "#entrada_srd_ita{$gram_srd}{$lemma_srd} = $#{$entrada_srd_ita{$gram_srd}{$lemma_srd}}\n";
#my $lemma_srd = 'abèssiér';
#print "#entrada_srd_ita{$gram_srd}{$lemma_srd} = $#{$entrada_srd_ita{$gram_srd}{$lemma_srd}}\n";
# tractament de les paraules
my %carregat_ita = ();
for (my $i = 0; $i <= $#data; $i++) {

	my $line = $data[$i]{line};
	my $lemma_srd = $data[$i]{lemma_srd};
	my $stem_srd = $data[$i]{stem_srd};
	my $gram_srd = $data[$i]{gram_srd};
	my $lemma_ita = $data[$i]{lemma_ita};
	my $stem_ita = $data[$i]{stem_ita};
	my $gram_ita = $data[$i]{gram_ita};
	my $autor = $data[$i]{autor};
	my $primer = $data[$i]{primer};

next if $lemma_ita eq 'habitant';
next if $lemma_ita eq 'rivière';
next if $lemma_ita eq 'montagne';
next if $lemma_ita eq 'ville';

	my $num_ita_srd	= (exists $entrada_ita_srd{$gram_ita}{$lemma_ita}) ? $#{$entrada_ita_srd{$gram_ita}{$lemma_ita}} + 1 : 0;
	my $num_srd_ita = (exists $entrada_srd_ita{$gram_srd}{$lemma_srd}) ? $#{$entrada_srd_ita{$gram_srd}{$lemma_srd}} + 1 : 0;

print "#entrada_ita_srd{$gram_ita}{$lemma_ita} - $num_ita_srd\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
print "#entrada_srd_ita{$gram_srd}{$lemma_srd} - $num_srd_ita\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
#print "entrada_srd_ita{$gram_srd}{$lemma_srd}[0] - $entrada_srd_ita{$gram_srd}{$lemma_srd}[0]\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
#print "entrada_srd_ita{$gram_srd}{$lemma_srd}[1] - $entrada_srd_ita{$gram_srd}{$lemma_srd}[1]\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;

	my $num_ita_srd_act	= (exists $dix_ita_srd{$gram_ita}{$lemma_ita}) ? $#{$dix_ita_srd{$gram_ita}{$lemma_ita}} + 1 : 0;
	my $num_srd_ita_act = (exists $dix_srd_ita{$gram_srd}{$lemma_srd}) ? $#{$dix_srd_ita{$gram_srd}{$lemma_srd}} + 1 : 0;
print "#dix_ita_srd{$gram_ita}{$lemma_ita} - $num_ita_srd_act\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
print "#dix_srd_ita{$gram_srd}{$lemma_srd} - $num_srd_ita_act\n" if $lemma_ita eq $MOT || $lemma_srd eq $MOT;
	if ($CARREGAR_UNICS) {
		if ($num_ita_srd == 1 && $num_srd_ita == 1) {
			;
		} elsif ($num_ita_srd > 1 && $num_srd_ita == 1) {
next if !$CARREGAR_MES1;
#$autor = 'prova';
			if ($carregat_ita{$lemma_ita}) {
				$primer = 0;
			} else {
				$primer = 1;
			}
		} else {
			if ($carregat_ita{$lemma_ita}) {
#print STDERR "CARREGAR_UNICS: passo per alt la parella $lemma_ita ($num_ita_srd) / $lemma_srd ($num_srd_ita)\n";
print "CARREGAR_UNICS: passo per alt la parella $lemma_ita ($num_ita_srd) / $lemma_srd ($num_srd_ita)\n" if $lemma_srd eq $MOT || $lemma_ita eq $MOT;
				next;
			} else {
#				next;
				if ($num_srd_ita_act == 0) {
					$dix_srd_ita{$gram_srd}{$lemma_srd}[0] = '__ficcio__';	# poso una entrada fictiva perquè es generi LR
				}
				$carregat_ita{$lemma_ita}++;	# el noto com a carregat per a no posar les següents traduccions sense RL
			}
		}
	}
	tractar_parella ($lemma_srd, $stem_srd, $gram_srd, $lemma_ita, $stem_ita, $gram_ita, $autor, $primer, $line);
	$carregat_ita{$lemma_ita}++;
}
