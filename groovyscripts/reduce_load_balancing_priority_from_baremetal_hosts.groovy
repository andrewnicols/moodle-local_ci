import jp.ikedam.jenkins.plugins.scoringloadbalancer.preferences.BuildPreference;
import jp.ikedam.jenkins.plugins.scoringloadbalancer.preferences.BuildPreferenceJobProperty;
import java.util.List;

def newPreference = new BuildPreference("baremetal", -1);
def List<BuildPreference> preferenceList = new ArrayList<BuildPreference>();
preferenceList.add(newPreference);
def newConfig = new BuildPreferenceJobProperty(preferenceList);

println newConfig.getBuildPreferenceList();


Jenkins.instance.getAllItems(AbstractProject).each { p ->
  def slaveLabel = new hudson.model.labels.LabelAtom("Slave");
  def labels = p.getAssignedLabel().toString();
  println "Inspecting " + p.fullDisplayName;
  if (labels != null) {
    if (labels  ==~ /.*docker.*/) {
      println "= Updating (" + labels + ")";

      println "= Removing existing preference";
      p.removeProperty(BuildPreferenceJobProperty);

      println "= Adding new preference";
      p.addProperty(newConfig);

      println "= Saving.";
      p.save();

      println "= List is now:";
      p.getProperty(BuildPreferenceJobProperty).getBuildPreferenceList().each { pref ->
        println "==== " + pref.getLabelExpression() + " => " + pref.getPreference();
      }
    } else {
      println "=> Skipping (" + labels + ")";
    }
  }
  println "==========================================";
}
