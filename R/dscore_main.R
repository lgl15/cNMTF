###############################################################
# cNMTF
#	3. Delta score functions
# 3.1 Main function to calculate delta scores from cNMTF results
#
# Corresponding author:
# Luis Leal, Imperial College London, email: lgl15@imperial.ac.uk
###############################################################


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Analyze cNMTF results
#' @description Main function to perform analysis of cNMTF results
#'
#[Input]:
#' @param trait.project Trait
#' @param name.exp Name of experiment to analyse
#' @param work.dat Working directory
#' @param alpha.cnmtf Significance level for the delta SNV score
#'
#[Output]:
#' @return Plots of delta scores and workspaces with results printed to files
#'
#' @md
#' @author Luis G. Leal, \email{lgl15@@imperial.ac.uk}
#' @family Scoring functions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



		analyze.cnmtf = function(trait.project = NULL, #Trait
														 name.exp = NULL, #Name of experiment to analyse
														 work.dat = NULL, #Working directory
														 alpha.cnmtf = NULL, #Significance level for the delta SNV score
														 d.conf = NULL, #A dataframe of patients by confounder variables
														 snps.known = NULL, #Optional. List of known SNVs associated with the disease
														 snps.known2 = NULL, #Optional. A second list of SNVs to depict on the Manhattan plots
														 tmap = NULL #Mapping of SNPs to genes, chr and genomic position
														 )
			{


		#-------------------------------------------------
		# 1. Load preprocessing data
		#-------------------------------------------------


					#Load workspace with preprocessing variables
					  cat("\n", "\n", rep("-",20), "\n", "\n")
						cat("Analysing results of experiment", name.exp, "in trait", trait.project, "\n", "\n")

					#Load list of SNPs and Patients included in the experiment after filtering R
						load( file = paste(work.dat,"cnmtf_", name.exp, ".RData", sep=""))
						R.snps <- get("clus.U", res.cnmtf[[1]])[,1]
						R.pats <- get("clus.V", res.cnmtf[[1]])[,1]

					#Filter current vectors and R matrix
						out = out[ colnames(R) %in% R.pats ]
						pop = pop[ colnames(R) %in% R.pats ]
						R = R[rownames(R) %in% R.snps, colnames(R) %in% R.pats]
						dim(R)




		#--------------------------------------------------------------------
		# 2. Calculate corrected p-values from Logistic Regression Models
		#--------------------------------------------------------------------


					#Load or calculate corrected p-values
					load.pvalues.file = TRUE

					#Declare file of LRM p-values
					lrm.pvalues.file = paste(work.dat, "lrm_pvals_", trait.project,".RData",sep="")

					#!!#Some variables to define the correction of pvalues
					correct.pvals = c("pca", "genomic control")[1]
					logistic.model = TRUE


					#Load workspace with LRM p-values or calculate them
					if( file.exists(lrm.pvalues.file) & load.pvalues.file == TRUE){

						cat("Workspace with LRM p-values loaded from file.", "\n")

						load(lrm.pvalues.file)

					}else{

						cat("Workspace with LRM p-values not found. Calculating raw pvalues.", "\n")

						#Filter confounder variables dataframe to contain same patients than R
						if( !is.null(d.conf) ){
							d.conf = d.conf[match( colnames(R), d.conf$patients), ]
						}


						#Calculate semi-corrected p-values (i.e., without correction for PS)
						pvals.lrm.n  <- regression.snps(out = as.numeric(out)-1,
																							R = R,
																							logistic.model = logistic.model, coding = "additive", d.conf = d.conf )



						#Calculate inflation factor
						(inflation.0 = median( qchisq( 1 - pvals.lrm.n, df = 1 ), na.rm = T) / 0.456 )


						#Correct LRM p-values using genomic control or PCA

						if(correct.pvals == "genomic control"){

							#Correct p-values using genomic control
							pvals.lrm = 1 - pchisq( qchisq( 1-pvals.lrm.n, df = 1 )/ inflation.0, df = 1 )


						}else if(correct.pvals == "pca"){


							#Define Number of PCs to retain in PCA
							n.pcs = 3

							#Perform PCA
							res.pca = dudi.pca(data.frame(t(R)), center = TRUE,  scale = TRUE, scannf = F, nf = n.pcs)

							#Vector of corrected pvalues
							lpvals.lrm.c = rep( list(NA), n.pcs)

							#Calculate corrected p-values adding different number of PCs
							for(i in 1:n.pcs){

										cat("Calculating corrected p-values with", i , "PCs", "\n")


										#Add PCs to the dataframe of confouders
										if( !is.null(d.conf) ){
											d.conf.pcs = cbind(d.conf, res.pca$li[,1:i])
										}else{
											d.conf.pcs = NULL
										}



										#Calculate corrected p-values (i.e., with correction for PS)
										lpvals.lrm.c [[i]]  <- regression.snps(out = as.numeric(out)-1,
																										R = R,
																										logistic.model = logistic.model, coding = "additive", d.conf = d.conf.pcs )

							}


							#Calculate inflation factor for corrected p-values
							inflation = rep(NA, n.pcs)
							for(i in 1:n.pcs){
								corrected.chisq = qchisq(1- lpvals.lrm.c [[i]],df=1)
								inflation[i] = median(corrected.chisq, na.rm = T)/0.456
							}


							#Plot the inflation factor vs number of PCs
							pdf( file = paste(work.dat, "inflation_factor.pdf", sep = ""), width = 7, height = 6)
							par(mfrow = c(1,1))
							plot(x = seq(0, length(inflation)), y = c(inflation.0,inflation), t="l", ylab="Genomic control factor lambda", xlab="Number of axes of variation (PCs)", las=1, ylim = c(1, max(c(inflation.0,inflation))))
							abline(h=1,lty =3)
							abline(h=1.1,lty =3)
							dev.off()


							#Correlation between the PCs-outcome and PCs-population
							cor.pcs = matrix(NA, nrow = ncol(res.pca$li), ncol = 2)
							colnames(cor.pcs) <- c("Corr( PC, outcome)", "Corr( PC, pop)")
							for(i in 1:ncol(res.pca$li)){
								cor.pcs[i,1] = kruskal.test( res.pca$li[,i], g = as.factor(out) )$p.value
								cor.pcs[i,2] = kruskal.test( res.pca$li[,i], g = as.factor(pop) )$p.value
							}
							cor.pcs


							#Select number of PCs to correct
							pvals.lrm = lpvals.lrm.c[[2]]


						}#End if correcting with PCA

						#Save pvalues from LRM

						save(list = c("pvals.lrm.n","pvals.lrm", "lpvals.lrm.c"),file = paste(work.dat,"lrm_pvals_", trait.project, ".RData",sep=""))

					}#End if file with pvalues exists



					#Replace p-value == 0 with p-value = 1e-10
					pvals.lrm.n[ pvals.lrm.n < 1e-10] <- 1e-10
					pvals.lrm[ pvals.lrm < 1e-10] <- 1e-10

					#Create QQplots of uncorrected and corrected p-values (without adjustment for Bonferroni)
					pdf( file = paste(work.dat, "qqplot.pdf", sep = ""), width = 7, height = 6)

					par(mfrow = c(1,2))
					qq.chisq( qchisq( 1 - pvals.lrm.n, df=1), main = "Uncorrected LRM", pvals = TRUE )
					qq.chisq( qchisq( 1 - pvals.lrm, df=1), main = "Corrected LRM", pvals = TRUE)

					dev.off()

					#Adjust p-values using Bonferroni
					#pvals.lrm.n = p.adjust(pvals.lrm.n , method = "bonferroni")
					#pvals.lrm = p.adjust(pvals.lrm , method = "bonferroni")

					#Define level of significance for LRM
					alpha.lrm = 0.05/length(pvals.lrm)



		#--------------------------------------------------------------------
		# 3. 	Find potential False Positive associations caused by PS in LRM
		#--------------------------------------------------------------------



					#Create object for Manhattan plots
					obj.manhattan = manhattan.table(l.snps = R.snps, tmap = tmap)
					tmanhattan = obj.manhattan[[1]]
					med.point = obj.manhattan[[2]]


					#Define set of potential false positives (pFPs)
					snps.fp.lrm	=	setdiff( R.snps[ pvals.lrm.n < alpha.lrm], R.snps[ pvals.lrm < alpha.lrm])

					#Define color for pFPs
					color.code = as.character( rep(gray.colors(2, start = 0.7, end = 0.8), 12) [ as.factor( tmanhattan$chr )] )
					color.code[ tmanhattan$snp %in% snps.fp.lrm ] <- "brown"


					#Open connection to print to PDF
					pdf(paste(work.dat, "lrm_manhattam.pdf", sep = ""), width = 8, height = 6)

							#Create manhattan plot of uncorrected and corrected p-values
							par(mfrow = c(1,2))
							manhattan.plot(pvalues = pvals.lrm.n[ match(tmanhattan$snp, R.snps)],  #pvalues of the SNPs in tmanhattan
														lchr = unique(tmanhattan$chr), #List of chromosomes
														color = color.code,
														pos.snps.known1 = NULL, pos.snps.known2 = which( tmanhattan$snp %in% snps.known2 ) , #Positions of known associations
														print.file = NULL, #PDF file to print plots
														alpha = alpha.lrm, #Significance level
														med.point = med.point) #parameter to place the axes labels in a manhattan plot

							manhattan.plot(pvalues = pvals.lrm[ match(tmanhattan$snp, R.snps)],  #pvalues of the SNPs in tmanhattan
														 lchr = unique(tmanhattan$chr), #List of chromosomes
														 color = color.code,
														 pos.snps.known1 = NULL, pos.snps.known2 = which( tmanhattan$snp %in% snps.known2 ) , #Positions of known associations
														 print.file = NULL, #PDF file to print plots
														 alpha = alpha.lrm, #Significance level
														 med.point = med.point) #parameter to place the axes labels in a manhattan plot

					dev.off()




					#Categorise the set of potential false positives
					snps.fp.lrm.cat = rep("None", length(R.snps))
					snps.fp.lrm.cat[ R.snps %in% snps.fp.lrm ] <- "FP"
					names(snps.fp.lrm.cat) <- R.snps

					#Save list of FP to the workspace of LRM
					save(list = c("pvals.lrm.n","pvals.lrm", "lpvals.lrm.c", "snps.fp.lrm.cat", "alpha.lrm"), file = paste(work.dat,"lrm_pvals_", trait.project, ".RData",sep=""))



		#------------------------------------------------
		# 4. Prepare data for analysis of clustering
		#------------------------------------------------


				  #Calculate MAF for all SNPs in original R matrix
					maf.snps = rowSums(R)/((ncol(R)*2))
					maf.snps.cat = cut(maf.snps, breaks = c(-1,0.01,0.05,1), labels = c("rare","low-freq","common"))
					#table(maf.snps.cat ); length(maf.snps.cat )



		#------------------------------------------------
		# 5. Analyze results of Consensus clustering
		#------------------------------------------------



				 	#Name and path to files of experiments
				 	file.exp = paste(work.dat,"cnmtf_",name.exp,".RData",sep="")
				 	file.ran = paste(work.dat,"randomizations_cnmtf_",name.exp,".RData",sep="")

				 	#PDF file name to print plots
				 	print.file.score =  paste(work.dat,"score_results_", name.exp,".pdf",sep="")
				 	print.file.cluster =  paste(work.dat,"cluster_results_", name.exp,".pdf",sep="")
				 	print.file.delta =  paste(work.dat,"delta_results_", name.exp,".pdf",sep="")

				 	#Workspace name to save lists of SNPs
				 	file.res.sd = paste(work.dat,"score_results_", name.exp,".RData",sep="")

				 	#Create lists to save results of experiments
				 	res.sd = list() #List to save results of function sd.score


					#Make plots of p-values
					sig.snp.nmtf = list() #Signifincant SNVs from cNMTF
					res.sd.plot = list() #List to save results of function sd.plot


					#Find significant associations with results of each experiemnt


							cat("\n", "Exploring cluster results of experiment", name.exp, "\n")


							#Define combinations of clusters to compare
							clus.a = as.list( unlist( mclapply( 1:nlevels(out), function(k) rep(k,nlevels(out)-k)) ) )
							clus.b = as.list( unlist( mclapply( 2:nlevels(out), function(k) seq(k,nlevels(out))) ) )


							#Plot clusterså
							plot.clusters (file.exp = file.exp , #Workspace of the experiment (created with function score.cnmtf)
														 snps.known = snps.known2, #List of known associations
														 print.file = print.file.cluster , #File to print plots
														 maf.snps = maf.snps.cat, #Minor allele frequencies of SNPs in the original R matrix without filtering
														 R.snps = R.snps) #List of SNPs in the original seed files

							dOn = delta.score(file.exp1 = file.exp , #Workspace of the experiments 1 and 2 (created with function score.cnmtf)
																snps.known =  snps.known, #List of known associations
																snps.known2 = setdiff(snps.known2, snps.known),
																print.file = print.file.delta  )#File to print plots


							#Find significant SNVs
							cat("\n", "Analysing results of experiment", name.exp, "\n")

							#Calculate SD
							res.sd = sd.score( file.exp =	file.exp, #Workspace of the experiment (created with function score.cnmtf)
																				path.exp = work.dat, #Path to files of experiment
																				name.exp = name.exp, #Name of experiment (trait and name.exp)
																				snps.known1 = snps.known,	#List of known associations
																				snps.known2 = setdiff(snps.known2, snps.known), #Second List of known associations
																				out = out, #Outcome vector
																				pop = pop, #Population vector
																				clus.a = clus.a, clus.b = clus.b, #List of patient clusters to use in the delta scores
																				use.randomisations = TRUE, #Use randomisations to find the optimal cutoff points for the delta scores
																				alpha.cnmtf = alpha.cnmtf, #Level of significance for the cutoff points
																				file.ran = file.ran) #Path to file of randomisations


							#Call function sd.plot with results of each experiemnt
							cat("\n", "Plotting results of experiment", name.exp, "\n")



							res.sd.plot = sd.plot(R.snps =  R.snps, #List of SNPs in the original seed files
																		 object.sd = res.sd, #Results from function pvalues.score
																		 work.dat = work.dat, #Working directory
																		 pvals.lrm = pvals.lrm, #P-values obtained in a LRM
													 					 alpha.lrm = alpha.lrm, #Significance level
																		 snps.known1 = snps.known2, #List of known associations
																		 snps.known2 = setdiff(snps.known2, snps.known),
																		 maf.snps = maf.snps.cat, #Minor allele frequencies of SNPs in the original R matrix without filtering
																		 kd.snps  = NULL, #Node degress of SNPs in the original Wu matrix without filtering
														 				 snps.fp.lrm =  snps.fp.lrm, #Potential False Positive association from LRM
																		 print.file = print.file.delta , #File to print plots
																		 tao.sd = NULL, #Treshold of SD. If NULL find the thresholds in object.sd
														 				 ylim.sd = c(-10,10), #Limits for axe y
														 				 clus.a = clus.a, clus.b = clus.b, #List of patient clusters to use in the delta scores
														 				 tmap = tmap, #Mapping of SNPs to genes, chr and genomic position
																		 trait.project = trait.project) #Trait/outcome



							#Extract lists of significant variants from LRM and cNMTF
							sig.snp.lrm = res.sd.plot[[2]]
							sig.snp.nmtf = res.sd.plot[[1]]

							#Print summaries
							l.pred = names(unlist(sig.snp.nmtf)) #Number of associations predicted (P)
							n.known = sum(l.pred %in% snps.known2) #Number of known associations retrieved (TP)
							cat("Number of associations predicted (P):", length(l.pred), "\n")
							cat("Number of known associations predicted (TP):", n.known, "\n")
							cat("List of predictions:", l.pred, "\n" )

							#Save results of the experiment in a workspace
							res.sd.plot.i = res.sd.plot
							res.sd.i = res.sd
							save(list = c( "res.sd.plot.i", "res.sd.i"), file = file.res.sd )




				return()

		 }
