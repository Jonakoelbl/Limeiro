package aspectj.bonus.validator;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;
import java.lang.reflect.Field;

import aspectj.annotation.ValidatorToProperty;
import aspectj.validator.InvalidValueException;
import aspectj.validator.Validator;

public aspect ValidatorMixinsAspect {

	declare parents: @ValidatorToProperty * implements ObservableObjectValidator;

	pointcut fieldWrite(ObservableObjectValidator target, Object newValue):
		set(* *..*)&& 
		args(newValue) 
		&& target(@ValidatorToProperty target)
		&& !withincode(*.new(..))
		&& within(@ValidatorToProperty *);

	void around(ObservableObjectValidator target, Object newValue): fieldWrite(target, newValue) {
		String fieldName = thisJoinPoint.getSignature().getName();
		String oldValue = (String) getValue(target, fieldName);
		
		proceed(target, newValue);
		
		if (oldValue != newValue)
			target.fieldChanged(fieldName, oldValue, newValue);
	}
	
	after(ObservableObjectValidator target) : initialization(* ..*.new(..) ) && target(target) {
		target.initialize();
	}

	//*****************************************************
	protected Object getValue(Object oldValue, String varName) {
		Object value = null;
		try {
			Field fieldName = oldValue.getClass().getDeclaredField(varName);
			fieldName.setAccessible(true);
			value = fieldName.get(oldValue);
		} catch (Throwable e) {
		}
		return value;
	}
	
	// *****************************************************

	private transient PropertyChangeSupport ObservableObject.changeSupport;
	
	public void ObservableObject.initialize(){
		this.changeSupport = new PropertyChangeSupport(this);
	}
	
	public void ObservableObject.removePropertyChangeListener(String propertyName, PropertyChangeListener listener) {
		this.changeSupport.removePropertyChangeListener(propertyName, listener);
	}

	public void ObservableObject.addValidator(String propertyName, final Validator<String> aValidator) {
		this.changeSupport.addPropertyChangeListener(propertyName, new PropertyChangeListener(){

			@Override
			public void propertyChange(PropertyChangeEvent evt) {
				if(aValidator.validate((String) evt.getOldValue()))
						throw new InvalidValueException();
			}			
		});
	}
	
	public void ObservableObject.fieldChanged(String propertyName, Object oldValue, Object newValue){
		this.changeSupport.firePropertyChange(propertyName, oldValue, newValue);
	}
	
}