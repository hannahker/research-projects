
# SETUP AND IMPORTS -------------------------------------------------------

setwd("C:/Users/hanna/Desktop/Winter2020/agent-based-modelling/assessments/a3/analysis")
pop1000 <- read.csv('pop_1000.csv', skip = 6, header = T) # skip the first 6 rows
tot_time_1000 <- read.csv('total-time-1000.csv', skip=6, header = T)
rt_1000 <- read.csv('runtime-1000.csv', skip=6, header = T)
rt_x3 <- read.csv('runtime-100-500-1000.csv', skip=6, header = T)
library(ggplot2)
library(viridis)
library("ggpubr")

# FOR RT X3 ---------------------------------------------------------------

# Basic reorg of data
head(rt_x3.sel)
rt_x3.sel <- rt_x3[,c(1, 2,3,7,8,9,10)]
colnames(rt_x3.sel)<- c('run_no', 'trust', 'num_turt', 'ticks', 'num_adopt', 'num_new', 'mean_deg_adopt')

# Select only population 1000 
rt_x3.1000 <- rt_x3.sel[rt_x3.sel$num_turt==1000,]
rt_x3.500 <- rt_x3.sel[rt_x3.sel$num_turt==500,]
rt_x3.100 <- rt_x3.sel[rt_x3.sel$num_turt==100,]

# All of the runs went to full diffusion
rt_x3.1000[rt_x3.1000$tick==2000 & rt_x3.1000$num_adopt!=1000,]

# Get the ticks to reach certain diffusion level
getMinTicks <- function(num){
  a <- rt_x3.1000[rt_x3.1000$num_adopt>=num,]
  b <- aggregate(a$ticks,
                         by = list(a$run_no, a$trust),
                         FUN=min)
  colnames(b) <- c('run_no', 'trust', 'ticks')
  return(b)
}

# Get the mean and sd to reach certain diffusion level
getAvgTicks <- function(data){
  b <- aggregate(data$ticks,
                 by = list(data$trust),
                 FUN=mean)
  c <- aggregate(data$ticks,
                 by = list(data$trust),
                 FUN=sd)
  colnames(b) <- c('trust', 'mean')
  colnames(c) <- c('trust', 'sd')
  return(as.data.frame(cbind(trust=b$trust, mean=b$mean, sd=c$sd)))
}

p_50 <- getMinTicks(500)
p_100 <- getMinTicks(1000)
p_75 <- getMinTicks(750)
p_25 <- getMinTicks(250)

p_90 <- getMinTicks(900)
p_95 <- getMinTicks(950)
p_85 <- getMinTicks(850)

s_100 <- getAvgTicks(p_100)
s_75 <- getAvgTicks(p_75)
s_50 <- getAvgTicks(p_50)
s_25 <- getAvgTicks(p_25)

s_85 <- getAvgTicks(p_85)

# Combine for all runs 
p_all <- as.data.frame(cbind(trust = p_100$trust, 
                             p_100= p_100$ticks, 
                             p_75=p_75$ticks, 
                             p_50 = p_50$ticks, 
                             p_25 = p_25$ticks))

# Combine and get mean and sd for each parameter setting 
s_all <- as.data.frame(cbind(trust=s_25$trust,
                             mean.25=s_25$mean,
                             sd.25=s_25$sd, 
                             mean.50=s_50$mean,
                             sd.50=s_50$sd, 
                             mean.75=s_75$mean,
                             sd.75=s_75$sd, 
                             mean.100=s_100$mean,
                             sd.100=s_100$sd))
# Box plots 
ggplot(p_all, (aes(group=trust, x=trust, y=p_100)))+
  geom_boxplot(fill='lightgray', color="black")+
  theme_classic()+
  theme(text=element_text(size=24,  family="serif"))+
  labs(x='Trust coefficient', y='Ticks')

ggsave('box_25.png')

# Line graphs 
makeline <- function(colour, mean, sd, ytitle){
  g <- ggplot(s_all, aes(x=trust, y=mean))+
        geom_point(color=colour, size=3)+
        #geom_point(tt_1000.sel, mapping=aes(x=trust, y=ticks))+
        geom_line(color=colour, size=1.5)+
        # geom_smooth(method = "lm")+
        geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.01, color=colour)+
        theme_minimal()+
        labs(x='Trust coefficient', y=ytitle)
  return(g)
  
}

makeline('#3f9e7d', s_all$mean.75, s_all$sd.75, 'Ticks to 75% adoption')



# Scatter plots 
p <- ggscatter(getAvgTicks(getMinTicks(910)), x = "trust", y = "mean", 
          add = "reg.line", 
          add.params = list(color = "blue", fill = "lightgray"), # Customize reg. line
          conf.int = TRUE, 
          cor.coef = TRUE, 
          cor.method = "pearson",
          cor.coeff.args = list(method = "pearson",label.sep = "\n"))
ggpar(p, 
      font.main = c(24, 'plain'),
      font.x = c(24, 'plain'),
      font.y = c(24, 'plain'),
      font.tickslab = c(24, 'plain'),
      ylab = 'Ticks', xlab='Trust Coefficient',
      font.family = c('serif'))

ggsave('corr_25.png')

# Heatmaps / Joyplot 
library(ggridges)
head(rt_x3.1000)

newadopt.mean <- aggregate(rt_x3.1000$num_new,
                        by=list(rt_x3.1000$trust, rt_x3.1000$ticks),
                        FUN=median)
colnames(newadopt.mean) <- c('trust', 'ticks', 'new')

degreenew.median <- aggregate(rt_x3.1000$mean_deg_adopt,
                              by=list(rt_x3.1000$trust, rt_x3.1000$ticks),
                              FUN=median)
colnames(degreenew.median) <- c('trust', 'ticks', 'degree')




# Only look at ticks up to 100 
lowticks <- lowadopt.mean[newadopt.mean$tick<50,]
lowtotticks <- totadopt.mean[totadopt.mean$tick<50,]
lowdegticks <- degreenew.median[degreenew.median$ticks<10,]

ggplot(data=lowdegticks, mapping=aes(x=ticks, y=trust, fill=degree))+
  geom_tile()+
  theme_minimal()

ggplot(lowdegticks, aes(x = ticks, y = trust, group = trust, height = degree)) + 
  geom_density_ridges(stat = "identity", alpha=0.5)+
  labs(x='Ticks', y='Trust Coefficient')+
  theme_classic()+
  theme(text=element_text(size=18,  family="serif"))

ggsave('new_adopts_median.png')

a <- c(90,	91,	92,	93,	94,	95,	95,	96,	97,	98,	99,	100)
b <- c(-0.79,	-0.77,	-0.74,	-0.72,	-0.71,	-0.66,	-0.66,	-0.64,	-0.63,	-0.48,	-0.38,	-0.24)
ab <- as.data.frame(cbind(a,b))         

p <- ggscatter(ab, x = "a", y = "b")
ggpar(p, 
      font.main = c(24, 'plain'),
      font.x = c(24, 'plain'),
      font.y = c(24, 'plain'),
      font.tickslab = c(24, 'plain'),
      ylab = 'R', xlab='Percent network adoption',
      font.family = c('serif'))

# FOR RT 1000 -------------------------------------------------------------

head(rt_1000)
# Check to see if any of the runs didn't get full diffusion
rt_1000[rt_1000$X.step.==2000 & rt_1000$count.turtles.with..adopted..!=1000,]

# FOR TOT TIME 1000 -------------------------------------------------------

tt_1000.sel <- tot_time_1000[,c(2,7)]
colnames(tt_1000.sel) <- c('trust', 'ticks')
agg.mean <- aggregate(tt_1000.sel, by=list(tt_1000.sel$trust), FUN = mean) 
agg.sd <- aggregate(tt_1000.sel, by=list(tt_1000.sel$trust), FUN = sd)
agg.sum <- as.data.frame(cbind(trust = agg.mean$trust, mean = agg.mean$ticks, sd = agg.sd$ticks))

# Box plot 
ggplot(tt_1000.sel, (aes(group=trust, x=trust, y=ticks)))+
  geom_boxplot()+
  theme_minimal()+
  labs(x='Trust coefficient', y='Ticks to 100% adoption')

# Line chart with error bars
# Shows no relationship between time to full diffusion and source trust coefficiant 
ggplot(agg.sum, aes(x=trust, y=mean))+
  geom_point()+
  geom_point(tt_1000.sel, mapping=aes(x=trust, y=ticks))+
  geom_line()+
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.01)+
  theme_minimal()+
  labs(x='Trust coefficient', y='Ticks to 100% adoption')


# FOR POP 1000 ------------------------------------------------------------

print(head(pop1000))
pop1000_sel <- pop1000[,c(1,4,8,9,10,11,12)]
colnames(pop1000_sel) <- c('run_num', 'source_trust', 'tick', 'num_adopt', 'num_new', 'mean_deg_adopt', 'mean_evc_adopt')
pop1000_avg <- aggregate(pop1000_sel,
                         by=list(pop1000_sel$source_trust, pop1000_sel$tick),
                         FUN = mean)

low <- pop1000_avg[pop1000_avg$tick<20,]

# Number aware at each tick
ggplot(data=low, mapping=aes(x=tick, y=source_trust, fill=num_adopt))+
  geom_tile()+
  scale_fill_viridis()+
  theme_minimal()

# Check to see if any of the runs didn't get full diffusion
pop1000_avg[pop1000_avg$tick==1000 & pop1000_avg$num_adopt!=1000,]

# For each source_trust, get the min ticks where prop_adopt == 1
all <- pop1000_avg[pop1000_avg$num_adopt==1000,]
ticks_to_full <- aggregate(all$tick,
                           by = list(all$source_trust),
                           FUN=min)
colnames(ticks_to_full) <- c('source_trust','min_tick')

# Ticks to full diffusion
ggplot(data=ticks_to_full, mapping=aes(y=min_tick, x=source_trust))+
  geom_point()+
  geom_smooth(method = "lm")+
  theme_minimal()

# Ticks to 50%
# For each source_trust, get the min ticks where prop_adopt == 1
all <- pop1000_avg[pop1000_avg$num_adopt>10,]
ticks_to_50p <- aggregate(all$tick,
                           by = list(all$source_trust),
                           FUN=min)
colnames(ticks_to_50p) <- c('source_trust', 'min_tick')

# Ticks to 50p diffusion
ggplot(data=ticks_to_50p, mapping=aes(y=min_tick, x=source_trust))+
  geom_point()+
  geom_smooth(method = "lm")+
  theme_minimal()

# DATA CLEANING AND FORMATTING --------------------------------------------

# Get only columns of interest
selected <- data[,c(1,2,3,8,9,10,11,12)] 
# Rename columns 
colnames(selected) <- c('run_num', 'source_trust', 'num_turt', 'tick', 'num_adopt', 'num_new', 'mean_deg_adopt', 'mean_evc_adopt')
# Add columns with proportions 
selected$prop_adopt <- selected$num_adopt/selected$num_turt
selected$prop_new <- selected$num_new/selected$num_turt
# Order data by the run number 
selected <- selected[order(selected$run_num),]

# Average all runs with the same parameters
averaged <- aggregate(selected,
                      by=list(selected$source_trust, selected$num_turt, selected$tick),
                      FUN=mean)

# Only look at ticks up to 100 
lowticks <- averaged[averaged$tick<100,]

# Just check for runs with 100 turtles and ticks less than 100
turta <- averaged[averaged$num_turt==100 & averaged$tick<100,]

# Check to see if any of the runs didn't get full diffusion
averaged[averaged$tick==1000 & averaged$prop_adopt!=1,]

# For each unique combo of num_turt and source_trust, get the min ticks where prop_adopt == 1
all <- averaged[averaged$prop_adopt==1,]
ticks_to_full <- aggregate(all$tick,
                           by = list(all$source_trust, all$num_turt),
                           FUN=min)
colnames(ticks_to_full) <- c('source_trust','min_tick')


# MAKING HEATMAPS ---------------------------------------------------------

# Percent aware at each tick
ggplot(data=turta, mapping=aes(x=tick, y=source_trust, fill=prop_adopt))+
  geom_tile()+
  theme_minimal()

# Ticks to full diffusion
ggplot(data=ticks_to_full, mapping=aes(x=num_turt, y=source_trust, fill=min_tick))+
  geom_tile()+
  theme_minimal()

# Percent new at each tick
ggplot(data=turta, mapping=aes(x=tick, y=source_trust, fill=prop_new))+
  geom_tile()+
  theme_minimal()

# Percent new at each tick
ggplot(data=turta, mapping=aes(x=tick, y=source_trust, fill=mean_evc_adopt))+
  geom_tile()+
  theme_minimal()

# CORRELATION ANALYSIS ----------------------------------------------------

# Relationship between source_trust and min_tick
ggplot(data=ticks_to_full)+
  geom_point(aes(x=min_tick, y=source_trust))+
  theme_minimal()
