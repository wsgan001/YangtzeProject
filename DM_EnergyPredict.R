library(data.table)
library(forecast)
library(ggplot2)
library(car)

#������������
load("����2016_2017��������.rdata")
load("2018-6-6.RData")#HZNU�õ�����

######
#���������ɵ��ܺ����ж��ܺ�ģ�ͽ�������
#ʵ���ܺ�=f(ʱ�������ܺģ������¶ȣ�etc)

data.regress.raw <- nn[on_ratio>0&total_elec>0& (month(time) == 5 | month(time) == 6),
                       c("build_code","time","temp_diff","on_ratio","set_temp","real_temp","w_temp","w_hum","time_sep","total_elec")]#�ļ��º�
scatterplotMatrix(data.regress.raw[,3:10],smoother.args=list(lty=2),plot.points = FALSE,main="ScatterPlot without 0 EC Data")
cor(data.regress.raw[, 3:10], use = "complete.obs")
#��ؾ�������(�����ܺļ�¼)
#             temp_diff    on_ratio    set_temp  real_temp      w_temp       w_hum   time_sep  total_elec
# total_elec  0.44015383 -0.04585804 -0.03313324  0.4272608  0.53695398 -0.14108668  0.8383870  1.00000000
#����Ծ���(�������ܺļ�¼)
#             temp_diff   on_ratio   set_temp  real_temp     w_temp       w_hum    time_sep   total_elec
# total_elec  0.002200785  0.7604641  0.1256533  0.1528087  0.6136918 -0.32046952  0.74128579  1.000000000

regressFit<-lm(total_elec~time_sep+on_ratio+w_temp+w_hum,data=data.regress.raw)
#�������
summary(regressFit)
confint(regressFit)
par(mfrow=c(1,1))
plot(regressFit)
qqPlot(regressFit,simulate=TRUE,id.method="identify")
residplot(regressFit)
durbinWatsonTest(regressFit)
crPlots(regressFit)
ncvTest(regressFit)
spreadLevelPlot(regressFit,id = TRUE)##���쳣
summary(gvlma(regressFit))

residplot <- function(fit, nbreaks=10) {
  z <- rstudent(fit)
  hist(z, breaks=nbreaks, freq=FALSE,xlab="Studentized Residual",main="Distribution of Errors")
  rug(jitter(z), col="brown")
  curve(dnorm(x, mean=mean(z), sd=sd(z)),
        add=TRUE, col="blue", lwd=2)
  lines(density(z)$x, density(z)$y,
        col="red", lwd=2, lty=2)
  legend("topright",
         legend = c( "Normal Curve", "Kernel Density Curve"),lty=1:2, col=c("blue","red"), cex=.7)
}